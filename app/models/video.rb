class Video < ActiveRecord::Base
  
  acts_as_video_fu 
  
  
  Video.create!(:title => "Some Title", :video_url => "http://www.youtube.com/watch?v=gEILFf2XSrM") 

  
  
  
  
  
  
  
  
end
