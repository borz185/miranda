class Api::ProfileController < ApplicationController
  before_action :authenticate_user!

  # GET /api/user/profile
  def show
    render_success(
      {
        id: current_user.id,
        email: current_user.email,
        full_name: current_user.full_name,
        address: current_user.address,
        account_number: current_user.account_number,
        balance: current_user.balance.to_f,
        bonus_points: current_user.bonus_points,
        tariff: current_user.tariff ? {
          id: current_user.tariff.id,
          name: current_user.tariff.name,
          speed: current_user.tariff.speed,
          price: current_user.tariff.price.to_f
        } : nil,
        discount_active: current_user.discount_active
      }
    )
  end

  # PATCH /api/user/profile
  def update
    if current_user.update(profile_params)
      render_success(
        {
          id: current_user.id,
          email: current_user.email,
          full_name: current_user.full_name,
          address: current_user.address
        },
        "Профиль обновлен успешно"
      )
    else
      render_error(current_user.errors.full_messages.join(', '), nil, :bad_request)
    end
  end

  private

  def profile_params
    params.require(:user).permit(:full_name, :address)
  end
end