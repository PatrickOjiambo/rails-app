class Api::V1::AlertsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_alert, only: [:show, :update, :destroy]
  
  def index
    alerts = current_user.alerts.includes(:alert_matches)
    
    render_success(
      ActiveModelSerializers::SerializableResource.new(
        alerts,
        each_serializer: AlertSerializer,
        include: ['recent_matches_count']
      ).as_json
    )
  end
  
  def show
    render_success(
      AlertSerializer.new(@alert, include: ['recent_matches']).as_json
    )
  end
  
  def create
    alert_service = Alerts::CreateService.new(
      user: current_user,
      params: alert_params
    )
    
    result = alert_service.call
    
    if result[:success]
      render_success(
        AlertSerializer.new(result[:alert]).as_json,
        status: :created
      )
    else
      render_error(
        'Failed to create alert',
        errors: result[:errors]
      )
    end
  end
  
  def update
    authorize @alert
    
    if @alert.update(alert_params)
      # Re-run matching for updated alert
      AlertProcessingJob.perform_async(@alert.id)
      
      render_success(AlertSerializer.new(@alert).as_json)
    else
      render_error('Failed to update alert', errors: @alert.errors)
    end
  end
  
  def destroy
    authorize @alert
    @alert.destroy!
    render_success({ message: 'Alert deleted successfully' })
  end