class BonusProduct < ApplicationRecord
  belongs_to :service, optional: true
  
  validates :name, :cost_in_points, presence: true
end