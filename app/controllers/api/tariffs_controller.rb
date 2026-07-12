class Api::TariffsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/tariffs
  def index
    tariffs = Tariff.all.map do |tariff|
      {
        id: tariff.id,
        name: tariff.name,
        speed: tariff.speed,
        price: tariff.price.to_f,
        is_popular: tariff.is_popular,
        description: tariff.description
      }
    end
    
    render_success(tariffs)
  end

  # PATCH /api/tariffs/select/:id
  def select
    tariff = Tariff.find_by(id: params[:id])
    
    unless tariff
      render_not_found("Тариф не найден")
      return
    end

    # Проверяем баланс
    if current_user.balance < tariff.price
      render_error(
        "Недостаточно средств для подключения тарифа. Требуется #{tariff.price.to_f} руб., доступно #{current_user.balance.to_f} руб."
      )
      return
    end

    # Списываем деньги
    current_user.balance -= tariff.price
    
    # Создаём транзакцию
    Transaction.create!(
      user: current_user,
      amount: -tariff.price,
      description: "Подключение тарифа '#{tariff.name}'"
    )
    
    # Начисляем бонусы (1 балл за каждые 100 руб.)
    bonus_earned = (tariff.price / 100).floor
    if bonus_earned > 0
      current_user.bonus_points += bonus_earned
    end
    
    # Меняем тариф
    current_user.tariff = tariff
    current_user.save!
    
    render_success(
      {
        id: current_user.id,
        tariff: {
          id: tariff.id,
          name: tariff.name,
          speed: tariff.speed,
          price: tariff.price.to_f
        },
        balance: current_user.balance.to_f,
        bonus_points: current_user.bonus_points,
        bonus_earned: bonus_earned
      },
      "Тариф успешно изменён. Начислено #{bonus_earned} бонусных баллов"
    )
  end
end