class Api::AuthController < ApplicationController
  # POST /api/auth/register
  def register
    user = User.new(user_params)
    
    if user.save
      render_success(
        {
          id: user.id,
          email: user.email,
          account_number: user.account_number,
          full_name: user.full_name
        },
        "Регистрация успешна",
        :created
      )
    else
      render_error(user.errors.full_messages.join(', '), nil, :bad_request)
    end
  end

  # POST /api/auth/login
  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      # Генерируем JWT токен
      token = generate_jwt(user.id)
      
      # Сохраняем токен в Redis с TTL 24 часа
      REDIS.setex("user_token:#{user.id}", 24.hours.to_i, token)
      
      render_success(
        {
          token: token,
          user: {
            id: user.id,
            email: user.email,
            full_name: user.full_name,
            account_number: user.account_number
          }
        },
        "Вход выполнен успешно"
      )
    else
      render_error("Неверный email или пароль", nil, :unauthorized)
    end
  end

  # POST /api/auth/logout
  def logout
    # Получаем user_id из токена
    user_id = decode_jwt(current_token)&.fetch('user_id', nil)
    
    if user_id
      REDIS.del("user_token:#{user_id}")
      render_success(nil, "Выход выполнен успешно")
    else
      render_error("Невалидный токен", nil, :unauthorized)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :full_name, :address)
  end

  def generate_jwt(user_id)
    payload = { user_id: user_id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def decode_jwt(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError
    nil
  end

  def current_token
    request.headers['Authorization']&.split(' ')&.last
  end
end