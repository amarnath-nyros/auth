 
class UserController < ApplicationController
           #~ require "RubyGems"
         #~ require "feedtools-0.2.29" 
         require 'csv'
         require 'pdf/writer'
         
  # Be sure to include AuthenticationSystem in Application Controller instead
 include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
before_filter :login
#~ http://articles.sitepoint.com/article/debug-rails-app-ruby-debug/2
     before_filter :find_user
  # say something nice, you goof!  something sweet.
  
  def index
redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end
   
    
   #~ def user_data
    #~ @feed = FeedTools::build_merged_feed feedurls
     #~ @feed = FeedTools::Feed.open(params[:feed_url])
      # You can first test it with a static feed url like this     vvvvvvvvv
 #~ @feed = FeedTools::Feed.open('http://www.inkakinada.com')
  #~ render :action=>"list"
         #~ end
    
def hello
if session[:user_id]
  @user=User.find(session[:user_id])
  pdf = PDF::Writer.new
 
  #~ constants.select do |const|
 #~ !inherited.key?(const) || inherited[const].object_id != const_get(const).object_id
  pdf.select_font "Times-Roman"
  pdf.text "\n Name: #{@user.fname} \n Email: #{@user.email} \n LastName: #{@user.lname} \n Dob: #{@user.dob} \n Address: #{@user.address} \n", :font_size => 12, :justification => :left
 #~ pdf.image "http://localhost:3000/public/images/rails.png" 
  #~ pdf.image "#{RAILS_ROOT}/public/#{@user.photo}" 

 pdf.image "#{RAILS_ROOT}/public/#{@user.photo}", :resize => 0.35, :justification => :center
    #~ @user is object and photo is field name in image
   pdf.save_as(params[:user].to_i)
      

end

end

 
   
  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
  
    if logged_in? 
      
        if self.current_user.status == false    
           flash[:notice]="Please activate your account"
           render :controller=>"user",:action=>"login"
        else
      
                 if params[:remember_me] == "1"
                self.current_user.remember_me
                cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
              end

              session[:user_id]=current_user.id 
              redirect_back_or_default(:controller => '/user', :action => 'show',:id =>current_user.permalink  )
              flash[:notice] = "Logged in successfully"
      end
    else 
           #~ flash.now[:error] = "Could not save client"
            flash[:notice]="Invalid user/password combination"
             render :controller=>"user",:action=>"login"
           end
       
     end
     
     

  def signup
    @user = User.new(params[:user])
    return unless request.post?
     #~ render :text => params[:user].inspect and return
      @user.status=0
    @user.save!
    self.current_user = @user
    Sendmail.deliver_mailit(current_user.email, current_user.fname,"5555",current_user.id)
    redirect_back_or_default(:controller => '/user', :action => 'login')
    flash[:notice] = "Thanks for signing up and Please check your mail"
  rescue ActiveRecord::RecordInvalid

  end
  

  
  def active
   @user = User.find(params[:id])
     @user.status=1
    @user.update_attributes(:status=>1)
    flash[:notice]="account activated"
   redirect_to :action=>"login"
      end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/user', :action => 'login')
  end
  
  
  




def forgot_password
    
  if session[:user_id].blank?
 
    if request.post?
      u= User.find_by_email(params[:user][:email])
      if u and u.send_new_password
        flash[:notice]  = "A new password has been sent by email."
        redirect_to :action=>'forgot_password'
      else
        flash[:notice3]  = "Couldn't send password"
      end
    end
    else
      redirect_to :action => 'index' and return
      end
  end
  
  def save_new_password
  @user = User.find(params[:id])
  @user.password = params[:value]
  @user.update_attributes(params[:user])
  redirect_to :action => 'index' and return
end
  
  
      
  def create

     @user = User.create( params[:user] )
     if @user.save
     redirect_to :action=>"show" ,:id=>@user.id
     else 
     #~ render :text => params[:user].inspect and return
     render :action=>"new"  
    #~ end
     end
     end
 
 

 
    def show
 #~ @user=User.find(params[:id])     
   @user=User.find(:first ,:conditions => ["permalink = ?",params[:id]] )
     #~ 

     end



def changepassword
  
if request.post?

     @opwd=params[:oldpassword]
  
    @user=User.authenticate(  @finduser.login ,params[:oldpassword])
         #~ render :text => params[:user].inspect and return
           #render :text =>"#{params[:oldpassword]} ,#{session[:user_name]} ,#{@user.name} " and return  
          if   !@user.blank?
               if  @user.update_attributes(:password=>params[:user][:password], 
                :password_confirmation => params[:user][:password_confirmation])
                 redirect_to :action=>"login"
                 flash[:notice]="Your Password Has been changed."
                 else
                    flash[:notice]="Two Passwords not match try again ."
                    render :action=>"changepassword" and return      
                  end
         else 
            flash[:notice]=" Old Password not match try again ."
             render :action=>"changepassword" and return      
           end
         end
         #~ render :layout=> false
end 
 
 
 
def update
    
  @user = User.find(:first ,:conditions => ["permalink = ?",params[:id]])
 if @user.update_attributes!(params[:user])
redirect_to :action => 'show',:id=>@user.permalink
 else
   #~ render :text => "hi" and return
  end
end
  

  
         
  def edit
  
       if session[:user_id] == params[:id].to_i
       @user=User.find(:first ,:conditions => ["permalink = ?",params[:val]] )
        else     
       flash[:notice]="Please Login for this page. "
       redirect_to :action=>"login"   
       end
       end


  def search
   search_value =params[:val]
    if !search_value.blank? 
      conditions = ["login LIKE ?", search_value+"%"]     
       @users=User.paginate :page=>params[:page],:conditions => conditions ,:per_page=>4
    end
    render :partial => "search" and return
  end

  


  def delete
 if session[:user_id]
@user=User.find(session[:user_id])
@user.delete
flash[:message]="user deleted"
 redirect_to :action => 'index'
end
end


def list
 
 #if params[:page]
 if params[:records].blank?
   @per_page = 5
  else
    @per_page = params[:records].to_i
  end
   @users = User.paginate :page => params[:page],  :per_page =>@per_page
      #~ else
       #~ @users=User.find(:all ,:conditions => ["permalink = ?",params[:id]] )
   #~ end
    #~ @users = User.paginate :page => params[:page],  :per_page =>4
 end
 
  def find_user
    if session[:user_id]
  @finduser = User.find(session[:user_id])
    end
 end
  
  
  
   def exportable
  @user = User.find(:all)
      respond_to do |wants|
 wants.csv { render :text => @user.to_csv(:columns => [:fname,:email,:gender])  } 
 end
    end



   def csv_import 
    
  if request.post?
  @parsed_file=CSV::Reader.parse(params[:user][:file])
     n=0
     @parsed_file.each  do |row|
     c=User.new
     c.login=row[1]
     c.email=row[2]
     c.gender=row[4]
     if c.save!
        n=n+1
       GC.start if n%50==0
     end
     flash.now[:message1]="CSV Import Successful,#{n} new records added to data base"
       end
      render :action=>"list"  
end
end
 
  end

