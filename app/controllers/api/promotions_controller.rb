class Api::PromotionsController < ApplicationController
  before_action :authenticate_user!

  # GET /api/promotions
  def index
    promotions = Promotion.active.map do |promo|
      {
        id: promo.id,
        title: promo.title,
        description: promo.description,
        image_url: promo.image_url
      }
    end
    
    render_success(promotions)
  end
end