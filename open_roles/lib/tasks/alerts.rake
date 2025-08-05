# This is our simulated background job runner.
namespace :alerts do
  desc "Check for new jobs matching user alerts and send notifications"
  task send_notifications: :environment do
    puts "Checking for new jobs to notify users about..."

    # Find jobs created in the last 24 hours. In a real app, this interval
    # would match how often this task is run (e.g., 15.minutes.ago).
    recent_jobs = Job.recent.includes(:company)

    if recent_jobs.empty?
      puts "No new jobs found. Exiting."
      next
    end

    # Group alerts by user to send one email per user
    alerts_by_user = Alert.includes(:user).group_by(&:user)
    
    alerts_by_user.each do |user, user_alerts|
      all_matching_jobs = []
      
      user_alerts.each do |alert|
        # Reuse the search logic to find matching jobs
        company_name, keywords = SearchesController.new.send(:parse_query, alert.query.downcase)
        
        matching_jobs = recent_jobs.select do |job|
          company_match = company_name.nil? || job.company.name.downcase == company_name
          keywords_match = keywords.all? do |keyword|
            job.title.downcase.include?(keyword) || job.description.downcase.include?(keyword)
          end
          company_match && keywords_match
        end
        
        all_matching_jobs.concat(matching_jobs)
      end
      
      # Remove duplicates
      all_matching_jobs.uniq!
      
      if all_matching_jobs.any?
        puts "Found #{all_matching_jobs.count} new job(s) for user #{user.email}. Sending email."
        # In development, use deliver_now for immediate email delivery
        # In production, use deliver_later for background processing
        if Rails.env.development?
          AlertMailer.new_jobs_notification(user_alerts.first, all_matching_jobs).deliver_now
        else
          AlertMailer.new_jobs_notification(user_alerts.first, all_matching_jobs).deliver_later
        end
      end
    end

    puts "✅ Done."
  end
end