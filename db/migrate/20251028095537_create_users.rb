class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.boolean :email_confirmed, default: false, null: false
      t.datetime :email_confirmed_at
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.integer :sign_in_count, default: 0, null: false

      t.timestamps
    end
  end
end
