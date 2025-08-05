class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic if Rails.env.production?
  
  default from: 'OpenRoles <noreply@openroles.com>'
  layout 'mailer'
  
  protected
  
  def mail_with_analytics(options = {})
    # Add tracking parameters for email analytics
    options[:headers] ||= {}
    options[:headers]['X-Mailer'] = 'OpenRoles Platform'
    
    mail(options)
  end
end

