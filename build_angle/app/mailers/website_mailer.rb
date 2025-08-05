class WebsiteMailer < ApplicationMailer
  default from: 'notifications@buildangle.com'

  def generation_complete_email(website_request)
    @website_request = website_request
    @website = @website_request.generated_website
    mail(to: @website_request.email, subject: 'Your BuildAngle Website is Ready!')
  end

  def deployment_confirmation_email(website_request, repo_url)
    @website_request = website_request
    @repo_url = repo_url
    mail(to: @website_request.email, subject: 'Your Website has been "Deployed"!')
  end
end