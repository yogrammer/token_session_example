FactoryBot.define do
  factory :access_token do
    user
    token { SecureRandom.urlsafe_base64(32) }
    user_agent { "Mozilla/5.0 Some client" }
    remote_host { "127.0.0.1" }
    expires_in { 7200 }
    revoked_at { nil }
  end
end
