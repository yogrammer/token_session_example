class GraphqlController < ApplicationController
  before_action :restrict_origin

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      current_user: current_user,
      current_session: current_session,
      request: request,
    }
    result = TokenSessionExampleSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    raise e unless Rails.env.development?
    handle_error_in_development e
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { error: { message: e.message, backtrace: e.backtrace }, data: {} }, status: 500
  end

  # Cheap CSRF protection, rejecting all requests from unknown origins
  def restrict_origin
    # Only apply to cookie auth (native apps with header auth don't need an Origin header)
    if authorization_cookie
      # Use Origin checker from Rack::Cors
      resources = Rack::Cors::Resources.new
      resources.origins(Rails.application.config.cors_origins)
      unless resources.allow_origin?(request.headers["Origin"])
        render json: { status: 403, error: "Origin not allowed" }, status: 403
      end
    end
  end
end
