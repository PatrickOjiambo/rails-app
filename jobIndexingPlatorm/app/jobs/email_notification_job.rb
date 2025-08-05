class EmailNotificationJob < ApplicationJob
  queue_as :mailers
  
  def perform(alert_id, match_ids)
    alert = Alert.find(alert_id)
    matches = AlertMatch.where(id: match_ids).includes(:job)
    
    # Group matches by frequency preference
    case alert.frequency
    when 'instant'
      send_instant_notification(alert, matches)
    when 'daily', 'weekly'
      send_digest_notification(alert, matches)
    end
    
    # Mark matches as notified
    matches.each(&:mark_as_notified!)
  end
  
  private
  
  def send_instant_notification(alert, matches)
    matches.each do |match|
      AlertMailer.new_job_match(alert, match).deliver_now
    end
  end
  
  def send_digest_notification(alert, matches)
    AlertMailer.digest_notification(alert, matches).deliver_now
  end