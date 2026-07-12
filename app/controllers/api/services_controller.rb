class Api::ServicesController < ApplicationController
  before_action :authenticate_user!

  # GET /api/services
  def index
    services = Service.active.map do |service|
      user_service = current_user.user_services.find_by(service: service)
      
      response = {
        id: service.id,
        name: service.name,
        description: service.description,
        monthly_fee: service.monthly_fee.to_f,
        is_enabled: user_service&.is_enabled || false
      }
      
      # Добавляем информацию о следующем списании
      if user_service&.is_enabled
        next_billing = (user_service.last_billing_at || user_service.activated_at) + 30.days
        response[:next_billing_date] = next_billing.to_date
        response[:is_bonus] = user_service.is_bonus
      end
      
      response
    end
    
    render_success(services)
  end

  # PATCH /api/services/toggle/:id
  def toggle
    service = Service.find_by(id: params[:id])
    
    unless service
      render_not_found("Услуга не найдена")
      return
    end

    user_service = current_user.user_services.find_or_initialize_by(service: service)
    
    if user_service.is_enabled
      # Отключаем услугу
      user_service.is_enabled = false
      user_service.save!
      
      render_success(
        {
          id: service.id,
          name: service.name,
          is_enabled: false
        },
        "Услуга отключена"
      )
    else
      # Включаем услугу и списываем плату
      if current_user.balance < service.monthly_fee
        render_error(
          "Недостаточно средств для подключения услуги. Требуется #{service.monthly_fee.to_f} руб., доступно #{current_user.balance.to_f} руб."
        )
        return
      end
      
      current_user.balance -= service.monthly_fee
      
      Transaction.create!(
        user: current_user,
        amount: -service.monthly_fee,
        description: "Подключение услуги '#{service.name}'"
      )
      
      # Начисляем бонусы
      bonus_earned = (service.monthly_fee / 100).floor
      current_user.bonus_points += bonus_earned if bonus_earned > 0
      
      user_service.is_enabled = true
      user_service.is_bonus = false  # Обычная услуга
      user_service.activated_at = Time.current
      user_service.last_billing_at = Time.current
      user_service.save!
      current_user.save!
      
      render_success(
        {
          id: service.id,
          name: service.name,
          is_enabled: true,
          is_bonus: false,
          bonus_earned: bonus_earned,
          next_billing_date: 30.days.from_now.to_date
        },
        "Услуга подключена. Начислено #{bonus_earned} бонусных баллов. Следующее списание: #{30.days.from_now.to_date}"
      )
    end
  end
end