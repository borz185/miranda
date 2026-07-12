class Api::ServicesController < ApplicationController
  before_action :authenticate_user!

  # GET /api/services
  def index
    services = Service.active.map do |service|
      user_service = current_user.user_services.find_by(service: service)
      
      {
        id: service.id,
        name: service.name,
        description: service.description,
        monthly_fee: service.monthly_fee.to_f,
        is_enabled: user_service&.is_enabled || false
      }
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
      
      # Начисляем бонусы (1 балл за каждые 100 руб.)
      bonus_earned = (service.monthly_fee / 100).floor
      if bonus_earned > 0
        current_user.bonus_points += bonus_earned
      end
      
      user_service.is_enabled = true
      user_service.activated_at = Time.current
      user_service.save!
      current_user.save!
      
      render_success(
        {
          id: service.id,
          name: service.name,
          is_enabled: true,
          bonus_earned: bonus_earned
        },
        "Услуга подключена. Начислено #{bonus_earned} бонусных баллов"
      )
    end
  end
end