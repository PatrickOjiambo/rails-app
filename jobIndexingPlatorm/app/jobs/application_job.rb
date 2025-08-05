class ApplicationJob < ActiveJob::Base
  include Sidekiq::Job
  
  retry_in do |count, exception|
    case exception
    when Net::TimeoutError, Faraday::TimeoutError
      10 * (count + 1) # 10, 20, 30 seconds
    else
      :kill # Don't retry unknown exceptions
    end
  end
  
  sidekiq_options retry: 3, backtrace: 10
end
