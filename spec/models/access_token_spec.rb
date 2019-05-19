require "rails_helper"

RSpec.describe AccessToken, type: :model do
  describe "#validates?" do
    context "when the token is valid" do
      subject { create(:access_token) }

      it "returns true" do
        expect(subject.validates?).to be(true)
      end
    end

    context "when the token is expired" do
      subject { create(:access_token, expires_in: 1, created_at: Time.now - 2.seconds) }

      it "returns false" do
        expect(subject.validates?).to be(false)
      end
    end

    context "when the token is revoked" do
      subject { create(:access_token, revoked_at: Time.now - 1.second) }

      it "returns false" do
        expect(subject.validates?).to be(false)
      end
    end
  end

  describe "#revoke" do
    context "unrevoked token" do
      subject { create(:access_token, revoked_at: nil) }

      it "sets the revoked_at time" do
        subject.revoke
        expect(subject.revoked_at).to be_instance_of(ActiveSupport::TimeWithZone)
      end
    end

    context "already revoked token" do
      subject { create(:access_token, revoked_at: Time.now - 1.day) }

      it "returns false" do
        expect(subject.revoke).to be(false)
      end

      it "doesn't change the revoked_at time" do
        expect(subject.revoked_at).to be < Time.now - 1.hour
      end
    end
  end
end
