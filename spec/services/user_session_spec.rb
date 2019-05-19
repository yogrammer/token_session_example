require "rails_helper"

RSpec.describe UserSession, type: :service do
  describe "#authenticate_by_email_password" do
    let(:email) { "testuser@example.com" }
    let(:password) { "test_password" }
    let!(:user) { create(:user, email: email, password: password) }

    context "with valid credentials" do
      let!(:auth_method) { subject.authenticate_by_email_password(email, password) }

      it "returns true" do
        expect(auth_method).to be(true)
      end

      it "sets the session's user" do
        expect(subject.user).to eq(user)
      end

      it "sets the session's token" do
        expect(subject.token).to be_instance_of AccessToken
      end
    end

    context "with invalid credentials" do
      let!(:auth_method) { subject.authenticate_by_email_password(email, "wrong_password") }

      it "returns false" do
        expect(auth_method).to be(false)
      end

      it "doesn't set the session's user" do
        expect(subject.user).to be_nil
      end

      it "doesn't set the session's token" do
        expect(subject.token).to be_nil
      end
    end
  end

  describe "#authenticate_by_token" do
    let(:user) { create(:user) }

    context "with a valid token" do
      let(:access_token) { create(:access_token, user: user) }
      let!(:auth_method) { subject.authenticate_by_token(access_token.token) }

      it "returns true" do
        expect(auth_method).to be(true)
      end

      it "sets the session's user" do
        expect(subject.user).to eq(user)
      end

      it "sets the session's token" do
        expect(subject.token).to be_instance_of AccessToken
      end
    end

    context "with an expired token" do
      let(:access_token) { create(:access_token, user: user, expires_in: 1, created_at: Time.now - 2.seconds) }
      let!(:auth_method) { subject.authenticate_by_token(access_token.token) }

      it "returns false" do
        expect(auth_method).to be(false)
      end

      it "doesn't set the session's user or token" do
        expect(subject.user).to be_nil
        expect(subject.token).to be_nil
      end
    end

    context "with a revoked token" do
      let(:access_token) { create(:access_token, user: user, revoked_at: Time.now - 1.second) }
      let!(:auth_method) { subject.authenticate_by_token(access_token.token) }

      it "returns false" do
        expect(auth_method).to be(false)
      end

      it "doesn't set the session's user or token" do
        expect(subject.user).to be_nil
        expect(subject.token).to be_nil
      end
    end

    context "with a non-existing token" do
      let!(:auth_method) { subject.authenticate_by_token("no token") }

      it "returns false" do
        expect(auth_method).to be(false)
      end

      it "doesn't set the session's user or token" do
        expect(subject.user).to be_nil
        expect(subject.token).to be_nil
      end
    end
  end

  describe "#end_session" do
    subject { UserSession.new(user: create(:user), token: create(:access_token)) }
    let!(:session_token) { subject.token }
    before { subject.end_session }

    it "revokes the session's token" do
      expect(session_token.revoked_at).to be_instance_of(ActiveSupport::TimeWithZone)
      expect(session_token.validates?).to be(false)
    end

    it "clears the session's user and token" do
      expect(subject.user).to be_nil
      expect(subject.token).to be_nil
    end
  end
end
