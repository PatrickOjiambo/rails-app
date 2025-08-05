# This file should ensure the database is seeded with required data in a idempotent way.
# The data can then be loaded with the `bin/rails db:seed` command.

puts "🌱 Seeding database..."

# Clean up previous data
Job.destroy_all
Company.destroy_all
Alert.destroy_all
User.destroy_all

# Create a sample user
user = User.create!(email: 'pashrick237@gmail.com')
puts "👤 Created sample user: #{user.email}"

# Create Companies
uber = Company.create!(name: 'Uber', slug: 'uber')
google = Company.create!(name: 'Google', slug: 'google')
shopify = Company.create!(name: 'Shopify', slug: 'shopify')

puts "🏢 Created #{Company.count} companies."

# Create Jobs
Job.create!([
  { company: uber, title: 'Senior Software Engineer', description: 'Build the future of transportation. Experience with Go and Python required.', location: 'San Francisco, CA', job_type: 'Full-time' },
  { company: uber, title: 'Product Marketing Manager', description: 'Market our new Uber Eats features.', location: 'New York, NY', job_type: 'Full-time' },
  { company: google, title: 'Software Engineer, Cloud', description: 'Work on Google Cloud Platform. Strong knowledge of distributed systems.', location: 'Mountain View, CA', job_type: 'Full-time' },
  { company: google, title: 'UX Designer', description: 'Design intuitive and beautiful user experiences for Google Search.', location: 'London, UK', job_type: 'Full-time' },
  { company: shopify, title: 'Senior Ruby Developer', description: 'Join the core platform team and work on one of the largest Rails applications in the world.', location: 'Ottawa, ON', job_type: 'Remote' },
  { company: shopify, title: 'Data Scientist (Python)', description: 'Analyze merchant data to provide insights and drive product strategy.', location: 'Toronto, ON', job_type: 'Remote' }
])

puts "💼 Created #{Job.count} jobs."

# Create some sample alerts for our user
Alert.create!([
    { user: user, query: 'software engineer at uber' },
    { user: user, query: 'remote python' }
])

puts "🔔 Created #{Alert.count} alerts."
puts "✅ Done seeding!"
