class CompaniesController < ApplicationController
  before_action :set_company, only: [:show]
  
  def index
    @companies = Company.active.includes(:active_jobs)
    @companies = @companies.search_by_name_and_description(params[:search]) if params[:search].present?
    @companies = @companies.page(params[:page]).per(20)
    
    @featured_companies = Company.active.joins(:active_jobs)
      .group('companies.id')
      .order('COUNT(jobs.id) DESC')
      .limit(6)
  end
  
  def show
    @jobs = @company.active_jobs.includes(:company)
    @jobs = @jobs.page(params[:page]).per(20)
    
    @job_stats = {
      total_jobs: @company.jobs_count,
      remote_jobs: @company.active_jobs.remote.count,
      recent_jobs: @company.active_jobs.recent.count
    }
    
    # SEO optimization
    @page_title = "#{@company.name} Jobs - All Open Positions"
    @page_description = "Browse #{@company.jobs_count} open positions at #{@company.name}. #{@company.description&.truncate(100)}"
  end
  
  private
  
  def set_company
    @company = Company.find_by!(slug: params[:id])
  end
end