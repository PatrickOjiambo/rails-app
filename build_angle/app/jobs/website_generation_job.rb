class WebsiteGenerationJob < ApplicationJob
  queue_as :default

  def perform(website_request_id)
    website_request = WebsiteRequest.find(website_request_id)
    puts "Starting website generation for request ##{website_request.id}..."

    generated_website = WebsiteGeneratorService.new(website_request).call

    if generated_website
      puts "Generation complete! Website ID: #{generated_website.id}. Sending notification."
      # TODO: Trigger the confirmation email
        WebsiteMailer.generation_complete_email(website_request).deliver_now

        # Let's also "deploy" it right away
        # mock_deploy(website_request)
    else
      puts "Generation failed for request ##{website_request.id}."
      # TODO: Trigger a failure email
    end
  end

end