class Service < ApplicationRecord
  has_many :user_services, dependent: :destroy
  has_many :users, through: :user_services

  validates :name, :monthly_fee, presence: true

  # Скоуп для получения только активных услуг
  scope :active, -> { where(is_active: true) }
end