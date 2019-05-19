class User < ApplicationRecord
  # rails built-in password hashing
  has_secure_password validations: false
  before_create { raise "Password digest missing on new record" if password_digest.blank? }

  validates_presence_of :email
  validates_uniqueness_of :email, case_sensitivity: false

  # Relations
  has_many :access_tokens

  # Generate and set a password
  def generate_password
    self.password = SecureRandom.random_bytes(10)
  end
end
