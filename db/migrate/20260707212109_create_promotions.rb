class CreatePromotions < ActiveRecord::Migration[8.0]
  def change
    create_table :promotions do |t|
      t.string :title, null: false
      t.text :description
      t.string :image_url
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end