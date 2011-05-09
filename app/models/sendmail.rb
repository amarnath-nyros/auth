class Sendmail < ActionMailer::Base
  
  def mailit(to, name, pass,user_id)
    @subject   = "Account activation ...#{user_id}"
    @body['name']=name
    @body['pass']=pass
    @body['user_id']=user_id
    @user_id=user_id
    @recipients = to 
    @from  = 'support@yourdomain.com'
     @content_type    = "text/html"
  end
  
 
 
 
 def passwordforgot(to, name, pass,user_id)
    @subject   = "Your password is ..."
    @body['name']=name
    @body['pass']=pass
    @body['user_id']=user_id
    @recipients = to
    @from  = 'support@yourdomain.com'
     @content_type    = "text/html"
  end
 
 
 
 
 
 
  #~ <a href="http://localhost:3000/user/save_new_password/<%= @user_id %>?value=<%=@pass %>">

  
end
