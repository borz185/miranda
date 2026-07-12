class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :monthly_fee, precision: 10, scale: 2, null: false
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end