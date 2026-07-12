class User < ApplicationRecord
  has_secure_password
  
  belongs_to :tariff, optional: true
  has_many :user_services, dependent: :destroy
  has_many :services, through: :user_services
  has_many :transactions, dependent: :destroy

  # validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
  
  validates :email, 
            presence: { message: "Email не может быть пустым" },
            uniqueness: { case_sensitive: false, message: "Email уже занят" },
            format: { with: EMAIL_REGEX, message: "Некорректный формат email" }
  validates :full_name, presence: { message: "Имя не может быть пустым" }
  validates :password, length: { minimum: 6, message: "Пароль должен быть не менее 6 символов" }, on: :create
  validates :account_number, presence: true, uniqueness: true

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