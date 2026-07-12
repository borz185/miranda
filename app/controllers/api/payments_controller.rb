class Api::PaymentsController < ApplicationController
  before_action :authenticate_user!

  # POST /api/payment/topup
  def topup
    amount = params[:amount].to_f
    
    if amount <= 0
      render_error("Сумма должна быть больше 0")
      return
    end
    
    current_user.balance += amount
    
    Transaction.create!(
      user: current_user,
      amount: amount,
      description: "Пополнение баланса"
    )
    
    current_user.save!
    
    render_success(
      {
        balance: current_user.balance.to_f,
        amount: amount
      },
      "Баланс успешно пополнен"
    )
  end

  # GET /api/payment/history
  def history
    transactions = current_user.transactions.order(created_at: :desc).limit(50).map do |t|
      {
        id: t.id,
        amount: t.amount.to_f,
        description: t.description,
        created_at: t.created_at.iso8601
      }
    end
    
    render_success(transactions)
  end
end