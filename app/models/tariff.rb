class Tariff < ApplicationRecord
  has_many :users

  validates :name, :speed, :price, presence: true
end