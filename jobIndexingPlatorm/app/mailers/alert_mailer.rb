class AlertMailer < ApplicationMailer
  def new_job_match(alert, match)
    @alert = alert
    @match = match  
    @job = match.job
    @company = @job.company
    @user = alert.user
    @unsubscribe_url = unsubscribe_alert_url(@alert.unsubscribe_token)
    
    subject = "New #{@company.name} role: #{@job.title}"
    
    mail_with_analytics(
      to: @user.email,
      subject: subject,
      template_name: 'new_job_match'
    )
  end
  
  def digest_notification(alert, matches)
    @alert = alert
    @matches = matches.includes(:job, job: :company)
    @user = alert.user
    @unsubscribe_url = unsubscribe_alert_url(@alert.unsubscribe_token)
    
    job_count = matches.count
    subject = "#{job_count} new job#{job_count == 1 ? '' : 's'} matching '#{alert.name}'"
    
    mail_with_analytics(
      to: @user.email,
      subject: subject,
      template_name: 'digest_notification'
    )
  end
  
  def weekly_digest(user, popular_jobs, trending_companies)
    @user = user
    @popular_jobs = popular_jobs
    @trending_companies = trending_companies
    
    mail_with_analytics(
      to: user.email,
      subject: 'Your weekly job market update',
      template_name: 'weekly_digest'
    )
  end
end