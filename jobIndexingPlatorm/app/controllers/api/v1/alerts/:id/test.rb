def test
    authorize @alert
    
    # Manually trigger alert processing for testing
    AlertProcessingJob.perform_async(@alert.id)
    
    render_success({ message: 'Alert test triggered' })
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