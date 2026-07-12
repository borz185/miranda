class User < ApplicationRecord
  has_secure_password
  
  belongs_to :tariff, optional: true
  has_many :user_services, dependent: :destroy
  has_many :services, through: :user_services
  has_many :transactions, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :account_number, presence: true, uniqueness: true
  validates :full_name, presence: true

  # Генерация лицевого счета при создании (790XXXXXXXX)
  before_validation :generate_account_number, on: :create

  private

  def generate_account_number
    return if account_number.present?
    
    loop do
      self.account_number = "790#{rand(10**9).to_s.rjust(9, '0')}"
      break unless User.exists?(account_number: account_number)
    end
  end
end