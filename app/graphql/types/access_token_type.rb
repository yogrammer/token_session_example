module Types
  class AccessTokenType < Types::BaseObject
    field :id, ID, null: false
    # field :user, UserType, null: false
    # field :token, String, null: false
    field :user_agent, String, null: true
    field :remote_host, String, null: true
    field :expires_in, String, null: false
    field :revoked_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :is_current, Boolean, null: false
    def is_current
      object.token == context[:current_session].token.token
    end


    # Only render user's own access_tokens
    def self.authorized?(object, context)
      super && (context[:current_user] && context[:current_user].access_tokens.include?(object))
    end
  end
end
