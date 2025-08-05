class AlertsController < ApplicationController
  # In a real app, this would be behind authentication
  # before_action :authenticate_user!

  def create
    # For this demo, we'll find or create the sample user.
    # In a real app, you'd use `current_user`.
    user = User.find_or_create_by!(email: 'pashrick237@gmail.com')

    @alert = user.alerts.new(alert_params)

    if @alert.save
      # Redirect back to the search page with a success message
      redirect_to search_path(query: @alert.query), notice: "✅ Alert created! We'll notify you of new jobs matching '#{@alert.query}'."
    else
      # Handle validation errors
      redirect_to search_path(query: @alert.query), alert: "Could not create alert."
    end
  end

  # This handles the unsubscribe link from the email.
  def unsubscribe
    alert = Alert.find_by(id: params[:id], unsubscribe_token: params[:token])

    if alert
      alert.destroy
      # You'd have a nice "You've been unsubscribed" page for this.
      render plain: "You have been successfully unsubscribed."
    else
      render plain: "Invalid unsubscribe link.", status: :not_found
    end
  end

  private

  def alert_params
    params.require(:alert).permit(:query)
  end
end