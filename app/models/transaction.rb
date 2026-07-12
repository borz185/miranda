class Transaction < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true
end