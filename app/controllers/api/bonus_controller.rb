class Api::BonusController < ApplicationController
  before_action :authenticate_user!

  # GET /api/bonus/products
  def products
    products = BonusProduct.all.map do |product|
      {
        id: product.id,
        name: product.name,
        cost_in_points: product.cost_in_points,
        description: product.description
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
    
    # Скидка - активируем флаг
    if product.name.include?("Скидка")
      current_user.discount_active = true
    end
    
    # Антивирус в подарок - включаем услугу
    if product.name.include?("Антивирус")
      service = Service.find_by(name: "Антивирус")
      if service
        user_service = current_user.user_services.find_or_initialize_by(service: service)
        user_service.is_enabled = true
        user_service.activated_at = Time.current
        user_service.save!
      end
    end
    
    current_user.save!
    
    render_success(
      {
        bonus_points: current_user.bonus_points,
        product: {
          id: product.id,
          name: product.name
        }
      },
      "Бонус успешно активирован"
    )
  end
end