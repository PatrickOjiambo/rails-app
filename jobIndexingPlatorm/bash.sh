# 1. Initial setup
bundle install
rails db:create

# 2. Generate all migrations (run each command above)
rails generate migration CreateCompanies name:string slug:string domain:string description:text logo_url:string headquarters:string size_category:integer industry:string social_links:json active:boolean last_scraped_at:datetime scraping_config:json

rails generate migration CreateJobs company:references title:string description:text location:string remote:boolean employment_type:string experience_level:string department:string salary_min:decimal salary_max:decimal salary_currency:string requirements:json benefits:json external_id:string external_url:string posted_at:datetime expires_at:datetime active:boolean
rails generate devise User first_name:string last_name:string email_verified:boolean last_active_at:datetime preferences:json
rails generate migration CreateAlerts user:references name:string query:text filters:json frequency:string active:boolean last_run_at:datetime total_matches:integer unsubscribe_token:string
rails generate migration CreateAlertMatches alert:references job:references match_score:decimal notified:boolean notified_at:datetime

# 4. Add search functionality
rails generate migration AddSearchToJobs

# 5. Run migrations
rails db:migrate