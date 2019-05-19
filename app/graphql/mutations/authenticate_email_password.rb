module Mutations
  class AuthenticateEmailPassword < Mutations::BaseMutation
    null true

    argument :email, String, required: true
    argument :password, String, required: true

    field :user, Types::UserType, null: true
    field :token, String, null: true
    field :errors, [String], null: false

    def resolve(email:, password:)
      session = UserSession.new(user_agent: context[:request].user_agent, remote_host: context[:request].remote_ip)
      auth = session.authenticate_by_email_password(email, password)

      if auth
        {
          user: session.user,
          token: session.token.token,
          errors: [],
        }
      else
        {
          user: nil,
          token: nil,
          errors: ["Invalid credentials"],
        }
      end
    end
  end
end
