namespace :billing do
  desc "Ежедневное списание за тарифы и услуги"
  task daily: :environment do
    puts " Запуск биллинга #{Time.current}..."
    
    # 1. Обработка тарифов
    User.where.not(tariff_id: nil).where.not(tariff_activated_at: nil).find_each do |user|
      days_since_activation = ((Time.current - user.tariff_activated_at) / 1.day).floor
      
      if days_since_activation >= 0
        tariff = user.tariff
        puts "  👤 Пользователь #{user.email}: тариф '#{tariff.name}' требует продления"
        
        if user.balance >= tariff.price
          # Списываем деньги
          user.balance -= tariff.price
          user.tariff_activated_at = Time.current  # Сбрасываем таймер
          
          Transaction.create!(
            user: user,
            amount: -tariff.price,
            description: "Ежемесячное списание за тариф '#{tariff.name}'"
          )
          
          # Начисляем бонусы
          bonus_earned = (tariff.price / 100).floor
          user.bonus_points += bonus_earned if bonus_earned > 0
          
          user.save!
          puts "    ✅ Списано #{tariff.price} руб. Баланс: #{user.balance}"
        else
          # Недостаточно средств — отключаем тариф
          old_tariff = tariff.name
          user.update(tariff: nil, tariff_activated_at: nil)
          
          Transaction.create!(
            user: user,
            amount: 0,
            description: "Тариф '#{old_tariff}' отключён из-за нехватки средств (требуется #{tariff.price} руб., доступно #{user.balance} руб.)"
          )
          
          puts "    ❌ Тариф отключён. Баланс: #{user.balance}"
        end
      end
    end
    
    # 2. Обработка услуг
    UserService.where(is_enabled: true).find_each do |user_service|
      last_billing = user_service.last_billing_at || user_service.activated_at
      days_since_billing = ((Time.current - last_billing) / 1.day).floor
      
      if days_since_billing >= 0
        service = user_service.service
        user = user_service.user
        
        puts "  👤 Пользователь #{user.email}: услуга '#{service.name}' требует продления"
        
        if user_service.is_bonus
          # Бонусная услуга — просто отключаем без списания
          user_service.update(is_enabled: false)
          
          Transaction.create!(
            user: user,
            amount: 0,
            description: "Бонусная услуга '#{service.name}' отключена (истёк срок 30 дней)"
          )
          
          puts "    🎁 Бонусная услуга отключена"
        else
          # Обычная услуга — пытаемся списать
          if user.balance >= service.monthly_fee
            user.balance -= service.monthly_fee
            user_service.last_billing_at = Time.current  # Сбрасываем таймер
            
            Transaction.create!(
              user: user,
              amount: -service.monthly_fee,
              description: "Ежемесячное списание за услугу '#{service.name}'"
            )
            
            # Начисляем бонусы
            bonus_earned = (service.monthly_fee / 100).floor
            user.bonus_points += bonus_earned if bonus_earned > 0
            
            user.save!
            user_service.save!
            
            puts "    ✅ Списано #{service.monthly_fee} руб. Баланс: #{user.balance}"
          else
            # Недостаточно средств — отключаем услугу
            user_service.update(is_enabled: false)
            
            Transaction.create!(
              user: user,
              amount: 0,
              description: "Услуга '#{service.name}' отключена из-за нехватки средств (требуется #{service.monthly_fee} руб., доступно #{user.balance} руб.)"
            )
            
            puts "    ❌ Услуга отключена. Баланс: #{user.balance}"
          end
        end
      end
    end
    
    puts "✅ Биллинг завершён!"
  end
  
  desc "Проверка статуса биллинга (без списаний)"
  task check: :environment do
    puts "📊 Статус биллинга на #{Time.current}..."
    
    User.where.not(tariff_id: nil).where.not(tariff_activated_at: nil).find_each do |user|
      days = ((Time.current - user.tariff_activated_at) / 1.day).floor
      remaining = 30 - days
      puts "  👤 #{user.email}: тариф '#{user.tariff.name}', до списания: #{remaining} дн."
    end
    
    UserService.where(is_enabled: true).find_each do |us|
      last = us.last_billing_at || us.activated_at
      days = ((Time.current - last) / 1.day).floor
      remaining = 30 - days
      type = us.is_bonus ? "🎁 БОНУС" : "💰 Обычная"
      puts "  👤 #{us.user.email}: услуга '#{us.service.name}' (#{type}), до списания: #{remaining} дн."
    end
  end
end