class CreateMagicLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :magic_links do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false, index: { unique: true }
      t.string :purpose, null: false
      t.datetime :expires_at, null: false, index: true
      t.datetime :used_at
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :magic_links, [:user_id, :purpose, :expires_at]
  end
end
