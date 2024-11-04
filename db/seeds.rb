# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(
  first_name: 'Polina',
  last_name: 'Oleynikova',
  email: 'shers.studios@outlook.com',
  password: 'o!N?3zdp&roBE7br',
  password_confirmation: 'o!N?3zdp&roBE7br',
  phone: '+1234567890',
  admin: true,
  terms_of_service: true
)
