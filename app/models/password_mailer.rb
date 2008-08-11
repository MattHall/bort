class PasswordMailer < ActionMailer::Base
  
  def forgot_password(password)
    setup_email(password.user)
    @subject << 'You have requested to change your password'
    @body[:url] = "http://YOURSITE/change_password/#{password.reset_code}"
  end

  def reset_password(user)
    setup_email(user)
    @subject << 'Your password has been reset.'
  end

  protected
  
  def setup_email(user)
    @recipients = "#{user.email}"
    @from = "ADMINEMAIL"
    @subject = "[YOURSITE] "
    @sent_on = Time.now
    @body[:user] = user
  end
end