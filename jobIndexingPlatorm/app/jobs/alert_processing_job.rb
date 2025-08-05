class AlertProcessingJob < ApplicationJob
  queue_as :alerts
  
  def perform(alert_id = nil)
    alerts = alert_id ? [Alert.find(alert_id)] : Alert.due_for_processing
    
    alerts.each do |alert|
      process_alert(alert)
    end
  end
  
  private
  
  def process_alert(alert)
    # Find new jobs since last run
    new_jobs = Job.active.where('created_at > ?', alert.last_run_at || 1.week.ago)
    
    new_jobs.each do |job|
      Alerts::MatchService.new(job).call_for_alert(alert)
    end
    
    # Send notifications if there are new matches
    unnotified_matches = alert.alert_matches.unnotified.recent
    
    if unnotified_matches.exists?
      EmailNotificationJob.perform_async(alert.id, unnotified_matches.pluck(:id))
    end
    
    alert.update!(last_run_at: Time.current)
  end
end