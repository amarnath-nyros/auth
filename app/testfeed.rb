  require "RubyGems"
    require "feed_tools"

    feedurls = 'http://www.sphred.com/combined_feed'
    # If you want to fetch more than one feed then comment the above feedurls variable and   uncomment the below one.
    #feedurls = %w(http://feeds.feedburner.com/Sphred_top_10_feeds   http://feeds.feedburner.com/Sphred_site_only http://feeds.feedburner.com/Sphred_site_feature)
    my_feeds = FeedTools::build_merged_feed feedurls

    my_feeds.title = 'Sphred.com Feed'
    my_feeds.copyright = 'SPhred'
    my_feeds.author = 'Nasir '
    my_feeds.id = "http://www.sphred.com/combined_feed"

    File.open('./my_feeds.xml', 'w') do |file|
      file.puts my_feeds.build_xml()
    end