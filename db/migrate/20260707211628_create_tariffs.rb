class CreateTariffs < ActiveRecord::Migration[8.0]
  def change
    create_table :tariffs do |t|
      t.string :name, null: false
      t.integer :speed, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :is_popular, default: false
      t.text :description
      t.timestamps
    end
  end
end