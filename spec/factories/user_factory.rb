FactoryBot.define do
  factory :user do
    email { |n| "test#{n}@example.com" }
    password { "test_password" }
    password_confirmation { "test_password" }
  end
end
