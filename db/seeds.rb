puts " Начинаем заполнение базы данных..."

# --- Тарифы ---
puts "Создаем тарифы..."
tariffs = [
  { name: "Стартовый", speed: 100, price: 300.00, is_popular: false, description: "Базовый тариф для интернета и соцсетей" },
  { name: "Домашний", speed: 300, price: 500.00, is_popular: true, description: "Оптимальный тариф для всей семьи" },
  { name: "Максимальный", speed: 1000, price: 900.00, is_popular: false, description: "Максимальная скорость для геймеров и стримеров" }
]

tariffs.each do |t|
  Tariff.find_or_create_by(name: t[:name]) do |tariff|
    tariff.speed = t[:speed]
    tariff.price = t[:price]
    tariff.is_popular = t[:is_popular]
    tariff.description = t[:description]
  end
end

# --- Услуги ---
puts "Создаем услуги..."
services = [
  { name: "Антивирус", monthly_fee: 150.00, description: "Надежная защита всех устройств в сети" },
  { name: "Родительский контроль", monthly_fee: 50.00, description: "Блокировка нежелательных сайтов" },
  { name: "Статический IP", monthly_fee: 100.00, description: "Постоянный белый IP-адрес" }
]

services.each do |s|
  Service.find_or_create_by(name: s[:name]) do |service|
    service.monthly_fee = s[:monthly_fee]
    service.description = s[:description]
    service.is_active = true
  end
end

# --- Акции ---
puts "Создаем акции..."
promotions = [
  { title: "Летний кэшбэк", description: "Получайте 10% кэшбэка бонусами за оплату интернета летом!", image_url: "https://via.placeholder.com/800x400/FF6600/FFFFFF?text=Summer+Cashback", is_active: true },
  { title: "Скидка на год", description: "Оплатите интернет на год вперед и получите скидку 15%", image_url: "https://via.placeholder.com/800x400/7B2FBE/FFFFFF?text=Year+Discount", is_active: true }
]

promotions.each do |p|
  Promotion.find_or_create_by(title: p[:title]) do |promo|
    promo.description = p[:description]
    promo.image_url = p[:image_url]
    promo.is_active = p[:is_active]
  end
end

# --- Бонусные товары ---
puts "Создаем бонусные товары..."
bonus_products = [
  { name: "Скидка 10% на следующий месяц", cost_in_points: 50, description: "Спишите баллы и получите скидку" },
  { name: "Антивирус в подарок", cost_in_points: 30, description: "Бесплатный месяц антивируса за баллы" }
]

bonus_products.each do |bp|
  BonusProduct.find_or_create_by(name: bp[:name]) do |product|
    product.cost_in_points = bp[:cost_in_points]
    product.description = bp[:description]
  end
end

# --- Тестовый пользователь ---
puts "Создаем тестового пользователя..."
user = User.find_or_initialize_by(email: "test@miranda.ru")
if user.new_record?
  user.password = "password123"
  user.password_confirmation = "password123"
  user.full_name = "Иван Петров"
  user.address = "г. Москва, ул. Ленина, д. 1, кв. 10"
  user.balance = 1200.00
  user.bonus_points = 150
  user.tariff = Tariff.find_by(name: "Домашний")
  user.save!
  puts "✅ Пользователь создан! Email: test@miranda.ru, Пароль: password123"
else
  puts "ℹ️ Пользователь уже существует."
end

puts " База данных успешно заполнена!"