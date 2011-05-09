require 'pdf/writer'

  pdf = PDF::Writer.new
  pdf.select_font "Times-Roman"
  pdf.text "Hello, Ruby.", :font_size => 12, :justification => :left

  pdf.save_as("hello.pdf")