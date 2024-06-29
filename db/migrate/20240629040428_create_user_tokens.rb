class CreateUserTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :user_tokens do |t|
      t.string :token
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at

      t.timestamps
    end
    add_index :user_tokens, :token, unique: true
  end
end
