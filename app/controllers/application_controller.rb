class ApplicationController < ActionController::API
  include ApiResponse

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    unless token
      render_unauthorized("Токен не предоставлен")
      return
    end

    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      user_id = decoded['user_id']
      
      # Проверяем, что токен есть в Redis
      stored_token = REDIS.get("user_token:#{user_id}")
      
      unless stored_token == token
        render_unauthorized("Токен недействителен или истек")
        return
      end
      
      @current_user = User.find(user_id)
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render_unauthorized("Невалидный токен")
    end
  end

  def current_user
    @current_user
  end
end