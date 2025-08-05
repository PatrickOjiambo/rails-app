class JobIndexingJob < ApplicationJob
  queue_as :default
  
  def perform(company_id)
    company = Company.find(company_id)
    result = Companies::SyncJobsService.new(company).call
    
    if result[:success] && result[:created] > 0
      # Trigger alert matching for new jobs
      AlertProcessingJob.perform_async
    end
    
    # Log metrics
    Rails.logger.info "Job sync completed for #{company.name}: #{result}"
  end
end