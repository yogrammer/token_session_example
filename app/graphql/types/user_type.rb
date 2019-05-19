module Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :email, String, null: false

    field :access_tokens, AccessTokenType.connection_type, null: true
    def access_tokens
      object.access_tokens.valid
    end

    def self.authorized?(object, context)
      super && (context[:current_user].try(:id) == object.id)
    end
  end
end
