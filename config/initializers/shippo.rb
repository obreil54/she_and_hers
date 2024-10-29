Shippo.api_token = if Rails.env.production?
  ENV['SHIPPO_LIVE_API_TOKEN']
else
  ENV['SHIPPO_TEST_API_TOKEN']
end
