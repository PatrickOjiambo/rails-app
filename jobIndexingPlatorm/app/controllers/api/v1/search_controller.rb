class Api::V1::SearchController < Api::V1::BaseController
  def index
    return render_error('Query parameter is required') if params[:q].blank?
    
    # Parse natural language query
    query_parser = Search::QueryParser.new(params[:q])
    parsed_query = query_parser.parse
    
    # Execute search
    search_service = Jobs::SearchService.new(
      query: parsed_query[:text],
      filters: parsed_query[:filters].merge(filter_params),
      page: params[:page],
      per_page: params[:per_page] || 25,
      user: current_user
    )
    
    result = search_service.call
    
    render_success(
      {
        query: params[:q],
        parsed_query: parsed_query,
        jobs: ActiveModelSerializers::SerializableResource.new(
          result[:jobs],
          each_serializer: JobSerializer,
          include: ['company']
        ).as_json,
        total_count: result[:total_count],
        suggestions: generate_search_suggestions(params[:q]),
        related_companies: find_related_companies(result[:jobs])
      },
      meta: pagination_meta(result[:jobs])
    )
  end
  
  def suggestions
    # Autocomplete suggestions
    term = params[:term]
    return render_success([]) if term.blank?
    
    suggestions = []
    
    # Job title suggestions
    job_titles = Job.active
      .where('title ILIKE ?', "%#{term}%")
      .group(:title)
      .limit(5)
      .pluck(:title)
    
    suggestions += job_titles.map { |title| { type: 'job_title', value: title } }
    
    # Company name suggestions  
    company_names = Company.active
      .where('name ILIKE ?', "%#{term}%")
      .limit(5)
      .pluck(:name)
      
    suggestions += company_names.map { |name| { type: 'company', value: name } }
    
    render_success(suggestions)
  end
  
  private
  
  def filter_params
    params.permit(:location, :remote, :employment_type, :experience_level, 
                 :salary_min, :salary_max, :sort_by)
  end
  
  def generate_search_suggestions(query)
    # Generate related search suggestions based on current query
    # Could use machine learning or simple keyword matching
    []
  end
  
  def find_related_companies(jobs)
    # Extract companies from current results for related suggestions
    jobs.includes(:company).limit(5).map(&:company).uniq
  end
end