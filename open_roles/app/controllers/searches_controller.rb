class SearchesController < ApplicationController
  def show
    @query = params[:query]
    @jobs = []

    if @query.present?
      # Start with all jobs and filter down
      results = Job.all

      # Parse the query to find keywords and a company name
      company_name, keywords = parse_query(@query.downcase)

      # Filter by company if one was found
      if company_name.present?
        company = Company.find_by('lower(name) = ?', company_name)
        results = results.where(company: company) if company
      end

      # Filter by keywords
      keywords.each do |keyword|
        results = results.where('lower(title) LIKE ? OR lower(description) LIKE ?', "%#{keyword}%", "%#{keyword}%")
      end

      @jobs = results.includes(:company).order(created_at: :desc)
    end
  end

  private

  # A simple parser for natural language queries.
  # It extracts a company name (if "at" is used) and other keywords.
  def parse_query(query)
    # Example: "software engineer at uber" -> company: "uber", keywords: ["software", "engineer"]
    parts = query.split(/\s+/)
    at_index = parts.index('at')
    
    company_name = nil
    keywords = []

    if at_index
      company_name = parts[at_index + 1]
      keywords = parts[0...at_index]
    else
      keywords = parts
    end

    [company_name, keywords]
  end
end