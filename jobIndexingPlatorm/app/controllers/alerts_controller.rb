class AlertsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_alert, only: [:show, :edit, :update, :destroy]
  
  def index
    @alerts = current_user.alerts.includes(:alert_matches)
    @recent_matches = AlertMatch.joins(:alert)
      .where(alerts: { user: current_user })
      .includes(:job, :alert, job: :company)
      .recent
      .limit(10)
  end
  
  def show
    @recent_matches = @alert.alert_matches
      .includes(:job, job: :company)
      .recent
      .limit(20)
  end
  
  def new
    @alert = current_user.alerts.build
    @alert.query = params[:q] if params[:q].present?
  end
  
  def create
    @alert = current_user.alerts.build(alert_params)
    
    if @alert.save
      # Trigger initial matching
      AlertProcessingJob.perform_async(@alert.id)
      
      redirect_to @alert, notice: 'Job alert created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @alert.update(alert_params)
      # Re-run matching for updated alert
      AlertProcessingJob.perform_async(@alert.id)
      
      redirect_to @alert, notice: 'Alert updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @alert.destroy!
    redirect_to alerts_path, notice: 'Alert deleted successfully!'
  end
  
  def unsubscribe
    alert = Alert.find_by!(unsubscribe_token: params[:token])
    alert.update!(active: false)
    
    @alert = alert
    render :unsubscribed
  end
  
  private
  
  def set_alert
    @alert = current_user.alerts.find(params[:id])
  end
  
  def alert_params
    params.require(:alert).permit(
      :name, :query, :frequency, :active,
      filters: [:location, :remote, :employment_type, :experience_level, 
               :salary_min, :salary_max, :company]
    )
  end
end
