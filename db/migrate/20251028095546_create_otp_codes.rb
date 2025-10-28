class CreateOtpCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :otp_codes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code, null: false
      t.string :purpose, null: false
      t.datetime :expires_at, null: false, index: true
      t.datetime :verified_at
      t.integer :attempts, default: 0, null: false
      t.integer :max_attempts, default: 3, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :otp_codes, [:user_id, :code, :purpose]
    add_index :otp_codes, [:user_id, :purpose, :expires_at]
  end
end
