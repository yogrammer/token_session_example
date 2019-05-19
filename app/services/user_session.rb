class UserSession
  attr_reader :user, :token, :user_agent, :remote_host

  def initialize(user: nil, token: nil, user_agent: "", remote_host: nil)
    @user = user
    @token = token
    @user_agent = user_agent
    @remote_host = remote_host
  end

  def authenticated?
    @token.present? && @token.validates?
  end

  # Create a session and an access token
  def authenticate_by_email_password(email, password)
    user = User.find_by(email: email.downcase)

    if user && user.authenticate(password)
      @user = user
      @token = create_access_token

      true
    else
      false
    end
  end

  # Create a session from an existing token
  def authenticate_by_token(token)
    access_token = AccessToken.find_by(token: token)

    if access_token && access_token.validates?
      access_token.touch

      @user = access_token.user
      @token = access_token

      true
    else
      false
    end
  end

  # Sign out
  def end_session
    @token.update revoked_at: Time.now
    @user = nil
    @token = nil

    true
  end

  # Sets up session object and returns user if everything checks out
  def self.by_token(token)
    session = self.new
    if session.authenticate_by_token(token)
      session.user
    else
      nil
    end
  end

  private

  def create_access_token
    AccessToken.create(user: @user, user_agent: @user_agent, remote_host: @remote_host)
  end
end
