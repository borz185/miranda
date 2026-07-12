class AddBillingFieldsToUsersAndUserServices < ActiveRecord::Migration[8.0]
  def change
    # Дата подключения тарифа
    add_column :users, :tariff_activated_at, :datetime
    
    # Флаг "бонусная услуга" и дата последнего списания
    add_column :user_services, :is_bonus, :boolean, default: false, null: false
    add_column :user_services, :last_billing_at, :datetime
  end
end