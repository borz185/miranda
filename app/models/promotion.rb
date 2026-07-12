class Promotion < ApplicationRecord
  validates :title, presence: true

  # Скоуп для получения только активных акций
  scope :active, -> { where(is_active: true) }
end