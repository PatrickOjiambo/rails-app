# app/services/website_generator_service.rb
class WebsiteGeneratorService
  def initialize(website_request)
    @request = website_request
    @website = nil
  end

  def call
    # 1. Update status to 'generating'
    @request.update!(status: :generating)

    # 2. Create the main website record
    create_generated_website

    # 3. Generate content for each page (This is our "Mock AI")
    generate_pages

    # 4. Update status to 'complete'
    @request.update!(status: :complete)

    # 5. Return the finished website
    @website
  rescue => e
    # Basic error handling
    @request.update!(status: :failed)
    Rails.logger.error "Website generation failed for request #{@request.id}: #{e.message}"
    nil
  end

  private

  def create_generated_website
    subdomain = "#{@request.business_type.parameterize}-#{SecureRandom.hex(3)}"
    @website = GeneratedWebsite.create!(
      website_request: @request,
      subdomain: subdomain
    )
  end

  def generate_pages
    # Define which pages to create
    page_types = ['homepage', 'about', 'services', 'contact']
    page_types << 'menu' if @request.business_type == 'Restaurant' # Dynamic page
    page_types << 'projects' if @request.business_type == 'Portfolio'

    page_types.each do |type|
      # In a real app, you'd call an LLM API here.
      # For now, we simulate with simple templates.
      title = type.humanize
      content = generate_mock_html(type)

      @website.generated_pages.create!(
        title: title,
        page_type: type,
        content: content
      )
      sleep(1) # Simulate the work of the AI
    end
  end

  # This is our Mock AI Content Generator
  def generate_mock_html(page_type)
    style = @request.design_preferences.downcase
    business = @request.business_type

    # A very simple templating system
    "<html><head><title>#{page_type.humanize}</title></head>" \
    "<body style='font-family: sans-serif; background-color: #{style == 'modern' ? '#f0f0f0' : '#fff'};'>" \
    "<h1>Welcome to the #{business} #{page_type.humanize} Page</h1>" \
    "<p>This page was generated based on your goal: '#{@request.goals}'.</p>" \
    "<p>Design style: #{style}.</p>" \
    "</body></html>"
  end
end