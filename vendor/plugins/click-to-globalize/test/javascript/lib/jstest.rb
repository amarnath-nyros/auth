#
# (c) 2005-2009 Prototype Team http://prototypejs.org
#

require 'rake/tasklib'
require 'thread'
require 'webrick'
require 'fileutils'
include FileUtils
require 'erb'

PLUGIN_ROOT      = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", ".."))
ASSETS_PATH      = File.join(PLUGIN_ROOT, "assets")
TEST_PATH        = File.join(PLUGIN_ROOT, "test", "javascript")
TEST_ASSETS_PATH = File.join(TEST_PATH, "assets")
TMP_TEST_PATH    = File.join(TEST_PATH, "tmp")
FIXTURES_PATH    = File.join(TEST_PATH, "fixtures")

class Browser
  def supported?; true; end
  def setup ; end
  def open(url) ; end
  def teardown ; end

  def host
    require 'rbconfig'
    Config::CONFIG['host']
  end
  
  def macos?
    host.include?('darwin')
  end
  
  def windows?
    host.include?('mswin')
  end
  
  def linux?
    host.include?('linux')
  end
  
  def applescript(script)
    raise "Can't run AppleScript on #{host}" unless macos?
    system "osascript -e '#{script}' 2>&1 >/dev/null"
  end
end

class FirefoxBrowser < Browser
  def initialize(path=File.join(ENV['ProgramFiles'] || 'c:\Program Files', '\Mozilla Firefox\firefox.exe'))
    @path = path
  end

  def visit(url)
    system("open -a Firefox '#{url}'") if macos?
    system("#{@path} #{url}") if windows? 
    system("firefox #{url}") if linux?
  end

  def to_s
    "Firefox"
  end
end

class SafariBrowser < Browser
  def supported?
    macos?
  end
  
  def setup
    applescript('tell application "Safari" to make new document')
  end
  
  def visit(url)
    applescript('tell application "Safari" to set URL of front document to "' + url + '"')
  end

  def teardown
    #applescript('tell application "Safari" to close front document')
  end

  def to_s
    "Safari"
  end
end

class IEBrowser < Browser
  def setup
    require 'win32ole' if windows?
  end

  def supported?
    windows?
  end
  
  def visit(url)
    if windows?
      ie = WIN32OLE.new('InternetExplorer.Application')
      ie.visible = true
      ie.Navigate(url)
      sleep 0.01 while ie.Busy || ie.ReadyState != 4
    end
  end

  def to_s
    "Internet Explorer"
  end
end

class KonquerorBrowser < Browser
  @@configDir = File.join((ENV['HOME'] || ''), '.kde', 'share', 'config')
  @@globalConfig = File.join(@@configDir, 'kdeglobals')
  @@konquerorConfig = File.join(@@configDir, 'konquerorrc')

  def supported?
    linux?
  end

  # Forces KDE's default browser to be Konqueror during the tests, and forces
  # Konqueror to open external URL requests in new tabs instead of a new
  # window.
  def setup
    cd @@configDir, :verbose => false do
      copy @@globalConfig, "#{@@globalConfig}.bak", :preserve => true, :verbose => false
      copy @@konquerorConfig, "#{@@konquerorConfig}.bak", :preserve => true, :verbose => false
      # Too lazy to write it in Ruby...  Is sed dependency so bad?
      system "sed -ri /^BrowserApplication=/d  '#{@@globalConfig}'"
      system "sed -ri /^KonquerorTabforExternalURL=/s:false:true: '#{@@konquerorConfig}'"
    end
  end

  def teardown
    cd @@configDir, :verbose => false do
      copy "#{@@globalConfig}.bak", @@globalConfig, :preserve => true, :verbose => false
      copy "#{@@konquerorConfig}.bak", @@konquerorConfig, :preserve => true, :verbose => false
    end
  end
  
  def visit(url)
    system("kfmclient openURL #{url}")
  end
  
  def to_s
    "Konqueror"
  end
end

class OperaBrowser < Browser
  def initialize(path='c:\Program Files\Opera\Opera.exe')
    @path = path
  end
  
  def setup
    if windows?
      puts %{
        MAJOR ANNOYANCE on Windows.
        You have to shut down Opera manually after each test
        for the script to proceed.
        Any suggestions on fixing this is GREATLY appreciated!
        Thank you for your understanding.
      }
    end
  end
  
  def visit(url)
    applescript('tell application "Opera" to GetURL "' + url + '"') if macos? 
    system("#{@path} #{url}") if windows? 
    system("opera #{url}")  if linux?
  end

  def to_s
    "Opera"
  end
end

# shut up, webrick :-)
class ::WEBrick::HTTPServer
  def access_log(config, req, res)
    # nop
  end
end

class ::WEBrick::BasicLog
  def log(level, data)
    # nop
  end
end

class WEBrick::HTTPResponse
  alias send send_response
  def send_response(socket)
    send(socket) unless fail_silently?
  end
  
  def fail_silently?
    @fail_silently
  end
  
  def fail_silently
    @fail_silently = true
  end
end

class WEBrick::HTTPRequest
  def to_json
    headers = []
    each { |k, v| headers.push "#{k.inspect}: #{v.inspect}" }
    headers = "{" << headers.join(', ') << "}"
    %({ "headers": #{headers}, "body": #{body.inspect}, "method": #{request_method.inspect} })
  end
end

class WEBrick::HTTPServlet::AbstractServlet
  def prevent_caching(res)
    res['ETag'] = nil
    res['Last-Modified'] = Time.now + 100**4
    res['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0'
    res['Pragma'] = 'no-cache'
    res['Expires'] = Time.now - 100**4
  end
end

class BasicServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    prevent_caching(res)
    res['Content-Type'] = "text/plain"
    
    req.query.each do |k, v|
      res[k] = v unless k == 'responseBody'
    end
    res.body = req.query["responseBody"]
    
    raise WEBrick::HTTPStatus::OK
  end
  
  def do_POST(req, res)
    do_GET(req, res)
  end
end

class SlowServlet < BasicServlet
  def do_GET(req, res)
    sleep(2)
    super
  end
end

class DownServlet < BasicServlet
  def do_GET(req, res)
    res.fail_silently
  end
end

class InspectionServlet < BasicServlet
  def do_GET(req, res)
    prevent_caching(res)
    res['Content-Type'] = "application/json"
    res.body = req.to_json
    raise WEBrick::HTTPStatus::OK
  end
end

class NonCachingFileHandler < WEBrick::HTTPServlet::FileHandler
  def do_GET(req, res)
    super
    set_default_content_type(res, req.path)
    prevent_caching(res)
  end
  
  def set_default_content_type(res, path)
    res['Content-Type'] = case path
      when /\.js$/   then 'text/javascript'
      when /\.html$/ then 'text/html'
      when /\.css$/  then 'text/css'
      when /\.json$/ then 'application/json'
      else 'text/plain'
    end
  end
end

class JavaScriptTestTask < ::Rake::TaskLib

  def initialize(name=:test)
    @name = name
    @tests = []
    @browsers = []

    @queue = Queue.new

    @server = WEBrick::HTTPServer.new(:Port => 4711) # TODO: make port configurable
    @server.mount_proc("/results") do |req, res|
      @queue.push(req)
      res.body = "OK"
    end
    @server.mount("/response", BasicServlet)
    @server.mount("/slow", SlowServlet)
    @server.mount("/down", DownServlet)
    @server.mount("/inspect", InspectionServlet)
    yield self if block_given?
    define
  end

  def define
    task @name do
      trap("INT") { @server.shutdown; exit }
      t = Thread.new { @server.start }
      
      # run all combinations of browsers and tests
      @browsers.each do |browser|
        if browser.supported?
          t0 = Time.now
          test_suite_results = TestSuiteResults.new

          browser.setup
          puts "\nStarted tests in #{browser}."
          
          @tests.each do |test|
            browser.visit(get_url(test))
            results = TestResults.new(@queue.pop.query, test[:url])
            print results
            test_suite_results << results
          end
          
          print "\nFinished in #{Time.now - t0} seconds."
          print test_suite_results
          browser.teardown
        else
          puts "\nSkipping #{browser}, not supported on this OS."
        end
      end

      @test_builder.teardown
      @server.shutdown
      t.join
    end
  end
  
  def get_url(test)
    params = "resultsURL=http://localhost:4711/results&t=" + ("%.6f" % Time.now.to_f)
    params << "&tests=#{test[:testcases]}" unless test[:testcases] == :all
    "http://localhost:4711#{test[:url]}?#{params}"
  end
  
  def mount(path, dir=nil)
    dir = Dir.pwd + path unless dir

    # don't cache anything in our tests
    @server.mount(path, NonCachingFileHandler, dir)
  end

  # test should be specified as a hash of the form
  # {:url => "url", :testcases => "testFoo,testBar"}.
  # specifying :testcases is optional
  def run(url, testcases = :all)
    @tests << { :url => url, :testcases => testcases }
  end

  def browser(browser)
    browser =
      case(browser)
        when :firefox
          FirefoxBrowser.new
        when :safari
          SafariBrowser.new
        when :ie
          IEBrowser.new
        when :konqueror
          KonquerorBrowser.new
        when :opera
          OperaBrowser.new
        else
          browser
      end

    @browsers<<browser
  end
end

class ClickToGlobalizeJavaScriptTestTask < JavaScriptTestTask
  def load_tests(test_cases)
    test_cases ||= Dir["#{TEST_PATH}/../**/*_test.js"]
    @test_cases = test_cases.map do |test_case|
      test_case = TestCase.new(test_case)
      raise "Unknown test #{test_case}." unless test_case.exist?
      test_case
    end
  end

  def prepare_tests
    @test_builder = TestBuilder.new(self, @test_cases)
    @test_builder.setup
  end

  def mount_paths
    mount "/",      TEST_ASSETS_PATH
    mount "/assets",     ASSETS_PATH
    mount "/fixtures", FIXTURES_PATH
    mount "/test",     TMP_TEST_PATH
  end
end

class TestResults
  attr_reader :tests, :assertions, :failures, :errors, :filename
  def initialize(query, filename)
    @tests      = query['tests'].to_i
    @assertions = query['assertions'].to_i
    @failures   = query['failures'].to_i
    @errors     = query['errors'].to_i
    @filename   = filename
  end
  
  def error?
    @errors > 0
  end
  
  def failure?
    @failures > 0
  end
  
  def to_s
    return "E" if error?
    return "F" if failure?
    "."
  end
end

class TestSuiteResults
  def initialize
    @tests      = 0
    @assertions = 0
    @failures   = 0
    @errors     = 0
    @error_files   = []
    @failure_files = []
  end
  
  def <<(result)
    @tests      += result.tests
    @assertions += result.assertions
    @failures   += result.failures
    @errors     += result.errors
    @error_files.push(result.filename)   if result.error?
    @failure_files.push(result.filename) if result.failure?
  end
  
  def error?
    @errors > 0
  end
  
  def failure?
    @failures > 0
  end
  
  def to_s
    str = ""
    str << "\n  Failures: #{@failure_files.join(', ')}" if failure?
    str << "\n  Errors:   #{@error_files.join(', ')}" if error?
    "#{str}\n#{summary}\n\n"
  end
  
  def summary
    "#{@tests} tests, #{@assertions} assertions, #{@failures} failures, #{@errors} errors."
  end
end

class TestBuilder
  TEMPLATE_PATH = File.join(TEST_PATH, "templates", "template.erb").freeze
  attr_reader :test_task

  def initialize(test_task, test_cases)
    @test_task, @test_cases = test_task, test_cases
    @template = ERB.new(File.new(TEMPLATE_PATH).read)
  end

  def setup
    create_temp_test_path
    @test_cases.each do |test_case|
      @test_case = test_case
      self.write_template
      self.test_task.run test_case.url
    end
  end

  def teardown
    destroy_temp_test_path
  end

  def create_temp_test_path
    destroy_temp_test_path
    FileUtils.mkdir_p File.join(TMP_TEST_PATH, "unit")
    FileUtils.mkdir_p File.join(TMP_TEST_PATH, "functional")
  end

  def destroy_temp_test_path
    FileUtils.rm_rf(TMP_TEST_PATH) rescue nil
  end

  protected
    def write_template
      template_path = File.join(TMP_TEST_PATH, @test_case.type, "#{@test_case.title}.html")
      File.open(template_path, 'w') { |f| f.write(@template.result(binding)) }
    end
end

class TestCase
  def initialize(path)
    @path = path
  end

  def title
    File.basename(@path, ".js")
  end

  def content
    File.new(@path).read
  end

  def type
    @path =~ /unit/ ? "unit" : "functional"
  end

  def url
    "/test/#{type}/#{title}.html"
  end

  def html_fixtures
    File.new(File.join(FIXTURES_PATH, type, "#{title.gsub("_test", "")}_fixtures.html")).read
  end

  def exist?
    File.exist?(@path)
  end

  def to_s
    name
  end
end
