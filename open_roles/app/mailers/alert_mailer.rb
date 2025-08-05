class AlertMailer < ApplicationMailer
  # Set a default from address
  default from: 'notifications@openroles.com'

  # The main notification method
  def new_jobs_notification(alert, jobs)
    @alert = alert
    @user = alert.user
    @jobs = jobs

    mail(
      to: @user.email,
      subject: "New Jobs Found for '#{@alert.query}'"
    )
  end
end