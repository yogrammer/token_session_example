class AccessToken < ApplicationRecord
  DEFAULT_TIMEOUT = 7200
  DEFAULT_LENGTH = 32

  belongs_to :user

  scope :valid, -> { where(revoked_at: nil).where("created_at + expires_in::text::interval > ?", Time.now) }

  before_create :set_defaults

  def validates?
    !expired? && !revoked?
  end

  def expired?
    created_at + expires_in < Time.now
  end

  def revoked?
    revoked_at.present?
  end

  def revoke
    if !revoked?
      update revoked_at: Time.now
    else
      false
    end
  end

  def touch
    update(updated_at: Time.now) if updated_at < (Time.now - 1.minute)
  end

  private

  def set_defaults
    self.expires_in ||= DEFAULT_TIMEOUT
    self.token ||= SecureRandom.urlsafe_base64(DEFAULT_LENGTH)
  end
end
