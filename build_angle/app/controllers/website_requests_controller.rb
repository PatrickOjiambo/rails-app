class WebsiteRequestsController < ApplicationController
  def show
    @website_request = WebsiteRequest.find(params[:id])
    # This view will show the status (e.g., "Your website is being generated...")
  end

  def new
    @website_request = WebsiteRequest.new
  end

  def create
    @website_request = WebsiteRequest.new(website_request_params)
    @website_request.status = :pending # Use the enum value

    if @website_request.save
  # Instead of doing the work here, we queue a job.
  WebsiteGenerationJob.perform_later(@website_request.id) # Use .id, it's safer for jobs.
  redirect_to @website_request, notice: 'Your request has been received! We will email you when your website is ready.'
else
  render :new
end
  end

  private

  def website_request_params
    params.require(:website_request).permit(:email, :business_type, :design_preferences, :goals, :content_needs, :target_audience)
  end
end