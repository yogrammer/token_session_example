FactoryBot.define do
  factory :user_session do
    user { create(:user) }
    token { create(:access_token) }
    user_agent { "Some/string" }
    remote_host { "127.0.0.1" }
  end
end
