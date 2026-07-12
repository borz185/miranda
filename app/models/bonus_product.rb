class BonusProduct < ApplicationRecord
  validates :name, :cost_in_points, presence: true
end