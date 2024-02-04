# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

statuses = ["Completed", "Cancelled", "Refunded"]

100.times do |i|
  Invoice.create!(
    amount: rand(100.0..1000.0).round(2),
    status: statuses.sample,
    created_at: rand(1..365).days.ago
  )
end
