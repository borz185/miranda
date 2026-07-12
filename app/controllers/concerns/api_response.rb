module ApiResponse
  extend ActiveSupport::Concern

  private

  def render_success(data = nil, message = nil, status = :ok)
    render json: { status: 'success', data: data, message: message }, status: status
  end

  def render_error(message, data = nil, status = :bad_request)
    render json: { status: 'error', data: data, message: message }, status: status
  end
  
  def render_not_found(message = "Ресурс не найден")
    render_error(message, nil, :not_found)
  end
  
  def render_unauthorized(message = "Необходима авторизация")
    render_error(message, nil, :unauthorized)
  end
end