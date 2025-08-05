class JobsController < ApplicationController
  before_action :set_job, only: [:show]
  
  def index
    @search_service = Jobs::SearchService.new(
      query: params[:q],
      filters: filter_params,
      page: params[:page],
      per_page: 20
    )
    
    @result = @search_service.call
    @jobs = @result[:jobs]
    @total_count = @result[:total_count]
    
    # For search filters UI
    @aggregations = build_filter_options
    @applied_filters = filter_params
  end
  
  def show
    @company = @job.company
    @similar_jobs = find_similar_jobs
    
    # Track job view
    track_job_view if current_user
    
    # SEO
    @page_title = "#{@job.title} at #{@company.name}"
    @page_description = @job.description&.truncate(160)
  end
  
  private
  
  def set_job
    @job = Job.active.includes(:company).find(params[:id])
  end
  
  def filter_params
    params.permit(:company, :location, :remote, :employment_type, 
                 :experience_level, :salary_min, :salary_max, :sort_by)
  end
  
  def build_filter_options
    # Build options for filter dropdowns
    {
      locations: Job.active.group(:location).limit(20).count.keys.compact,
      employment_types: Job.employment_types.keys,
      experience_levels: Job.experience_levels.keys,
      companies: Company.active.joins(:active_jobs).limit(50).pluck(:name, :slug)
    }
  end
  
  def find_similar_jobs
    # Find similar jobs based on title, company, or skills
    Job.active
      .where.not(id: @job.id)
      .where('title ILIKE ? OR company_id = ?', "%#{@job.title.split.first}%", @job.company_id)
      .limit(5)
  end
  
  def track_job_view
    # Track for analytics and recommendations
    # Could use a separate analytics service
  end
end