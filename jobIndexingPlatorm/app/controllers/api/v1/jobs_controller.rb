class Api::V1::JobsController < Api::V1::BaseController
  before_action :set_job, only: [:show]
  
  def index
    jobs_service = Jobs::SearchService.new(
      query: params[:q],
      filters: filter_params,
      page: params[:page],
      per_page: params[:per_page] || 25,
      user: current_user
    )
    
    result = jobs_service.call
    
    render_success(
      {
        jobs: ActiveModelSerializers::SerializableResource.new(
          result[:jobs],
          each_serializer: JobSerializer,
          include: ['company']
        ).as_json,
        total_count: result[:total_count],
        filters_applied: result[:filters_applied],
        aggregations: build_aggregations(result[:jobs])
      },
      meta: pagination_meta(result[:jobs])
    )
  end
  
  def show
    authorize @job
    
    render_success(
      JobSerializer.new(@job, include: ['company', 'similar_jobs']).as_json
    )
  end
  
  private
  
  def set_job
    @job = Job.active.includes(:company).find(params[:id])
  end
  
  def filter_params
    params.permit(:company, :location, :remote, :employment_type, 
                 :experience_level, :salary_min, :salary_max, :sort_by)
  end
  
  def build_aggregations(jobs_scope)
    # Build faceted search aggregations for filtering UI
    base_scope = jobs_scope.except(:limit, :offset)
    
    {
      locations: base_scope.group(:location).limit(10).count,
      companies: base_scope.joins(:company).group('companies.name').limit(10).count,
      employment_types: base_scope.group(:employment_type).count,
      experience_levels: base_scope.group(:experience_level).count,
      remote_distribution: {
        remote: base_scope.where(remote: true).count,
        on_site: base_scope.where(remote: false).count
      }
    }
  end
end