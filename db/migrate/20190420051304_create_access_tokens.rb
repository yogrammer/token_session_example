class CreateAccessTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :access_tokens, id: :uuid do |t|
      t.belongs_to :user, type: :uuid, null: false, foreign_key: true
      t.string :token, null: false
      t.string :user_agent, null: false
      t.inet :remote_host
      t.integer :expires_in, null: false
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
