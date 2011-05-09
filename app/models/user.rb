require 'digest/sha1'
class User < ActiveRecord::Base

 has_permalink :login
 #~ has_many :videos, :as => :resource
 #~ acts_as_videoclub
 
 acts_as_csv_exportable :default, [:id,:login, :gender, :email]
 acts_as_csv_importable :default, [:id, :login, :gender, :email]
  
 acts_as_csv_importable :new_users, [{:user_name => :login}, {:user_email => :email}, {:user_email => :gender}]
  # Virtual attribute for the unencrypted password
  attr_accessor :password_confirmation,:post
  #~ validates_acceptance_of :post
 #~ validates_presence_of     :login, :email,:address,:gender ,:description,:dob,:on=>:create
 #~ validates_presence_of     :password,                   :if => :password_required?
 #~ validates_presence_of     :password_confirmation,      :if => :password_required?
 #~ validates_attachment_presence :photo,:message => "Missing required Image location"  , :on=>:create
 #~ validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
 #~ validates_length_of       :password, :within => 4..40, :if => :password_required?,:on=>:create
  #~ validates_confirmation_of :password,                   :if => :password_required?
  #~ validates_length_of       :login,    :within => 3..40
  #~ validates_length_of       :email,    :within => 3..100
  #~ validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password
  
   has_attached_file :photo,:whiny => false,
    :styles => {
      :thumb=> "100x100#",
      :smalls  => "150x150>",:smallsthumb => "150x150#" }

      
      #~ file_column :filename, :magick => { 
 #~ :versions => { "thumb" => "50x50", "medium" => "640x480>" }
  #~ }

#~ video = @user.videos.build(params[:video][:source_url]) unless params[:video][:source_url].blank?
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
 #~ before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    
def as_videos?
  
  	  video = @flat.videos.build(params[:video][:source_url]) unless params[:video][:source_url].blank?
         video.save
  
  end

#~ video_embed_code(@user.videos.first, options)
	
	#~ Options accepted: width, height

    
    
    #~ def password 
          #~ @password
          #~ end

      #~ def password=(password) 
          #~ @password = password 
          #~ return if password.blank? 
          #~ create_new_salt 
          #~ self.hashed_password = User.encrypted_password(self.password, self.salt)
      #~ end
 
        #~ def self.authenticate(name, password)
          #~ user =User.find_by_name(name)
          #~ if user
          #~ expected_password = encrypted_password(password, user.salt)
          #~ if user.hashed_password != expected_password
          #~ user = nil
       #~ end
   #~ end
#~ user
#~ end
     

 #~ def send_new_password
    #~ new_pass = User.random_string(5)
    #~ self.password = self.password_confirmation = new_pass
    #~ self.save
    #~ Sendmail.deliver_passwordforgot(self.email, self.name, new_pass,self.id)
  #~ end

        #~ def create_new_salt 
            #~ self.salt = self.object_id.to_s + rand.to_s
        #~ end

          #~ def self.encrypted_password(password, salt) 
            #~ string_to_hash = password+"wibble"+salt  
            #~ Digest::SHA1.hexdigest(string_to_hash)
          #~ end 

 
 #~ def  mailpassword
    #~ newpassword = User.random_string(6)
    #~ self.password = self.password_confirmation = newpassword
    #~ self.save
    #~ Notifications.deliver_forgot_password(self.email, self.name, newpassword,self.id)
  #~ end
  
  #~ private
        #~ def password_non_blank 
            #~ errors.add(:password,"Missing password")if hashed_password.blank?
        #~ end


#~ def self.random_string(len)
    #~ #generat a random password consisting of strings and digits
    #~ chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a 
    #~ newpass = ""
    #~ 1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    #~ return newpass
  #~ end

    
    
end
