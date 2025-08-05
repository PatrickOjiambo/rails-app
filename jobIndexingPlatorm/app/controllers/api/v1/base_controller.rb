class Api::V1::BaseController < ApplicationController
  include Pundit::Authorization
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_default_format
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActionController::ParameterMissing, with: :bad_request
  
  protected
  
  def set_default_format
    request.format = :json unless params[:format]
  end
  
  def render_success(data, status: :ok, meta: {})
    render json: {
      success: true,
      data: data,
      meta: meta
    }, status: status
  end
  
  def render_error(message, status: :unprocessable_entity, errors: {})
    render json: {
      success: false,
      message: message,
      errors: errors
    }, status: status
  end
  
  def not_found
    render_error('Resource not found', status: :not_found)
  end
  
  def forbidden  
    render_error('Access denied', status: :forbidden)
  end
  
  def bad_request
    render_error('Invalid request parameters', status: :bad_request)
  end
end