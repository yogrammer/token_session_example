class ApplicationController < ActionController::API
  def current_user
    @current_user ||= current_session.try(:user)
  end

  def current_session
    if @current_session
      @current_session
    else
      session = UserSession.new
      if session.authenticate_by_token(authorization_header || authorization_cookie)
        @current_session = session
      end
    end
  end

  private

  def authorization_header
    request.env.fetch("HTTP_AUTHORIZATION", "").scan(/Bearer (.*)$/i).flatten.last
  end

  def authorization_cookie
    CGI.unescape(request.cookies.fetch("authorization", "")).presence
  end
end
