Rails.application.routes.draw do
  namespace :api do
    # Авторизация
    post 'auth/register', to: 'auth#register'
    post 'auth/login', to: 'auth#login'
    post 'auth/logout', to: 'auth#logout'
    
    # Профиль пользователя
    get 'user/profile', to: 'profile#show'
    patch 'user/profile', to: 'profile#update'

    # Тарифы
    get 'tariffs', to: 'tariffs#index'
    patch 'tariffs/select/:id', to: 'tariffs#select'
    
    # Услуги
    get 'services', to: 'services#index'
    patch 'services/toggle/:id', to: 'services#toggle'
    
    # Платежи
    post 'payment/topup', to: 'payments#topup'
    get 'payment/history', to: 'payments#history'
    
    # Акции
    get 'promotions', to: 'promotions#index'
    
    # Бонусы
    get 'bonus/products', to: 'bonus#products'
    post 'bonus/buy/:id', to: 'bonus#buy'
  end
end