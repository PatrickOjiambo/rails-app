class Jobs::SearchService
  include ActiveModel::Model
  
  attr_accessor :query, :filters, :page, :per_page, :user
  
  def initialize(params = {})
    @query = params[:query]
    @filters = params[:filters] || {}
    @page = params[:page] || 1
    @per_page = params[:per_page] || 25
    @user = params[:user]
  end
  
  def call
    log_search_query
    
    results = base_search
    results = apply_filters(results)
    results = apply_sorting(results)
    results = paginate_results(results)
    
    {
      jobs: results,
      total_count: results.total_count,
      filters_applied: applied_filters_summary,
      search_time: benchmark_time
    }
  end
  
  private
  
  def base_search
    if query.present?
      parsed_query = Search::QueryParser.new(query).parse
      Job.active.includes(:company).search_full_text(parsed_query[:text])
    else
      Job.active.includes(:company)
    end
  end
  
  def apply_filters(results)
    # Location filtering
    if filters[:location].present?
      results = results.where(
        "location ILIKE ? OR remote = ?", 
        "%#{filters[:location]}%", 
        true
      )
    end
    
    # Company filtering
    if filters[:company].present?
      results = results.joins(:company)
        .where(companies: { slug: filters[:company] })
    end
    
    # Salary filtering
    if filters[:salary_min].present?
      results = results.where('salary_min >= ?', filters[:salary_min])
    end
    
    # Experience level
    if filters[:experience_level].present?
      results = results.where(experience_level: filters[:experience_level])
    end
    
    # Remote only
    if filters[:remote] == true
      results = results.where(remote: true)
    end
    
    results
  end
  
  def apply_sorting(results)
    case filters[:sort_by]
    when 'newest'
      results.order(posted_at: :desc)
    when 'salary'
      results.order(salary_max: :desc, salary_min: :desc)
    when 'company'
      results.joins(:company).order('companies.name ASC')
    else
      # Default: relevance for search, newest for browse
      query.present? ? results : results.order(posted_at: :desc)
    end
  end
  
  def paginate_results(results)
    results.page(page).per(per_page)
  end
  
  def log_search_query
    SearchQuery.create!(
      user: user,
      query: query,
      filters_applied: filters,
      ip_address: request_ip
    ) if should_log?
  end
  
  # Additional private methods...
end

# app/services/alerts/match_service.rb
class Alerts::MatchService
  def initialize(job)
    @job = job
  end
  
  def call
    Alert.active.find_each do |alert|
      score = calculate_match_score(alert, @job)
      
      if score >= minimum_match_threshold
        create_alert_match(alert, score)
      end
    end
  end
  
  private
  
  def calculate_match_score(alert, job)
    # NLP matching algorithm
    # Combine multiple factors:
    # - Text similarity (title, description)
    # - Filter matching (location, salary, etc.)
    # - Company preferences  
    # - Historical user behavior
    
    text_score = calculate_text_similarity(alert.query, job)
    filter_score = calculate_filter_match(alert.parsed_filters, job)
    
    # Weighted combination
    (text_score * 0.7) + (filter_score * 0.3)
  end
  
  def calculate_text_similarity(query, job)
    # Implementation using PostgreSQL similarity or external NLP service
    # Could integrate with OpenAI embeddings for semantic matching
  end
  
  def create_alert_match(alert, score)
    AlertMatch.find_or_create_by(alert: alert, job: @job) do |match|
      match.match_score = score
    end
  end
end
