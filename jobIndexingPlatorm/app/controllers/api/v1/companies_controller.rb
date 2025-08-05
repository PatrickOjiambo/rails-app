class Api::V1::CompaniesController < Api::V1::BaseController
  before_action :set_company, only: [:show, :jobs]
  
  def index
    companies = Company.active.includes(:active_jobs)
    companies = companies.search_by_name_and_description(params[:search]) if params[:search].present?
    companies = companies.page(params[:page]).per(params[:per_page] || 20)
    
    render_success(
      ActiveModelSerializers::SerializableResource.new(
        companies, 
        each_serializer: CompanySerializer,
        include: ['jobs_count']
      ).as_json,
      meta: pagination_meta(companies)
    )
  end
  
  def show
    render_success(
      CompanySerializer.new(@company, include: ['active_jobs']).as_json
    )
  end
  
  def jobs
    jobs_service = Jobs::SearchService.new(
      query: params[:q],
      filters: { company: @company.slug }.merge(filter_params),
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
        search_time: result[:search_time]
      },
      meta: pagination_meta(result[:jobs])
    )
  end
  
  private
  
  def set_company
    @company = Company.find_by!(slug: params[:id])
  end
  
  def filter_params
    params.permit(:location, :remote, :employment_type, :experience_level, 
                 :salary_min, :salary_max, :sort_by)
  end
  
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end
end