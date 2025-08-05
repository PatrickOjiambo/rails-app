class Api::V1::JobsController < ApplicationController

  def index
    # Find company by its user-friendly slug
    company = Company.find_by(slug: params[:company_id])

    if company
      @jobs = company.jobs.order(created_at: :desc)
      # Rails automatically looks for a view at app/views/api/v1/jobs/index.json.jbuilder
      # Or we can render JSON directly:
      render json: @jobs, status: :ok
    else
      render json: { error: 'Company not found' }, status: :not_found
    end
  end
end