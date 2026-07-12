class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :description
      t.timestamps
    end
    add_index :transactions, [:user_id, :created_at]
  end
end