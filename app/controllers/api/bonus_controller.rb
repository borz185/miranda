class Api::BonusController < ApplicationController
  before_action :authenticate_user!

  # GET /api/bonus/products
  def products
    products = BonusProduct.all.map do |product|
      {
        id: product.id,
        name: product.name,
        cost_in_points: product.cost_in_points,
        description: product.description,
        service_name: product.service&.name  # Показываем, какую услугу дает
      }
    end
    
    render_success(products)
  end

  # POST /api/bonus/buy/:id
  def buy
    product = BonusProduct.find_by(id: params[:id])
    
    unless product
      render_not_found("Товар не найден")
      return
    end
    
    if current_user.bonus_points < product.cost_in_points
      render_error(
        "Недостаточно бонусных баллов. Требуется #{product.cost_in_points}, доступно #{current_user.bonus_points}"
      )
      return
    end
    
    current_user.bonus_points -= product.cost_in_points
    
    # Cкидка - активируем флаг
    if product.name.downcase.include?("скидка")
      current_user.discount_active = true
    end
    
    # Включаем услугу как бонусную
    if product.service
      user_service = current_user.user_services.find_or_initialize_by(service: product.service)
      user_service.is_enabled = true
      user_service.is_bonus = true # Помечаем как бонусную
      user_service.activated_at = Time.current
      user_service.last_billing_at = nil # Не было оплаты деньгами
      user_service.save!
    end
    
    current_user.save!
    
    render_success(
      {
        bonus_points: current_user.bonus_points,
        product: {
          id: product.id,
          name: product.name
        },
        expires_at: 30.days.from_now.to_date
      },
      "Бонус успешно активирован. Услуга будет отключена через 30 дней без списания средств"
    )
  end
end