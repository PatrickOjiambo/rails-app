Rails.application.routes.draw do
  # ... other routes
  
  # A singular resource for our search feature
  resource :search, only: [:show]

  # Landing page
  root 'searches#show'
  # API Namespace
  namespace :api do
    namespace :v1 do
      resources :companies, only: [] do
        # Nested route to get jobs for a specific company
        # GET /api/v1/companies/uber/jobs
        resources :jobs, only: [:index]
      end
    end
  end

    # Allow users to create alerts and unsubscribe
  resources :alerts, only: [:create] do
    # Use a member route with the token for unsubscribing
    # GET /alerts/:id/unsubscribe?token=...
    get :unsubscribe, on: :member
  end
end