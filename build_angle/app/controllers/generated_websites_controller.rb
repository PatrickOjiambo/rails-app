class GeneratedWebsitesController < ApplicationController
  def show
    @website = GeneratedWebsite.find_by!(subdomain: params[:subdomain])
    # By default, show the homepage
    @page = @website.generated_pages.find_by!(page_type: 'homepage')

    render_page
  end

  def show_page
    @website = GeneratedWebsite.find_by!(subdomain: params[:subdomain])
    @page = @website.generated_pages.find_by!(page_type: params[:page_type])

    render_page
  end

  private

  def render_page
    # The preview view will contain the navigation and render the page content
    render 'preview', layout: false # We don't want the main app layout
  end
end