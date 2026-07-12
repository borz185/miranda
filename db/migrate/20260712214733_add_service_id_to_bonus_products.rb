class AddServiceIdToBonusProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :bonus_products, :service, foreign_key: true, null: true
  end
end