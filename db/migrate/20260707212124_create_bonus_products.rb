class CreateBonusProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :bonus_products do |t|
      t.string :name, null: false
      t.integer :cost_in_points, null: false
      t.text :description
      t.timestamps
    end
  end
end