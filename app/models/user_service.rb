class UserService < ApplicationRecord
  belongs_to :user
  belongs_to :service

  # Скоуп для услуг, требующих продления
  scope :due_for_billing, -> { 
    where(is_enabled: true)
      .where("activated_at <= ? OR last_billing_at <= ?", 30.days.ago, 30.days.ago)
  }
end