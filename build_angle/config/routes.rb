Rails.application.routes.draw do
  get 'generated_websites/show'
  # Set the root to our questionnaire
  root 'website_requests#new'

  # Routes for creating and viewing the request status
  resources :website_requests, only: [:new, :create, :show]
resources :generated_websites, only: [:show], param: :subdomain do
  get 'page/:page_type', to: 'generated_websites#show_page', as: 'page'
end
  # We'll add the preview route later
end