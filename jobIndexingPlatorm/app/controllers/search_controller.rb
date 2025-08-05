class SearchController < ApplicationController
  def index
    redirect_to jobs_path(q: params[:q]) if params[:q].present?
  end
  
  def suggestions
    # AJAX endpoint for search autocomplete
    term = params[:term]
    
    suggestions = []
    
    if term.present?
      # Job titles
      job_titles = Job.active
        .where('title ILIKE ?', "%#{term}%")
        .group(:title)
        .limit(5)
        .pluck(:title)
      
      suggestions += job_titles.map { |title| { label: title, category: 'Job Titles' } }
      
      # Company names
      company_names = Company.active
        .where('name ILIKE ?', "%#{term}%")
        .limit(5)
        .pluck(:name)
        
      suggestions += company_names.map { |name| { label: name, category: 'Companies' } }
    end
    
    render json: suggestions
  end
end