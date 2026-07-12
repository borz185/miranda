class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false
      t.string :address
      t.string :account_number, null: false
      t.decimal :balance, precision: 10, scale: 2, default: 0.00
      t.integer :bonus_points, default: 0
      t.references :tariff, foreign_key: true
      t.boolean :discount_active, default: false
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :account_number, unique: true
  end
end