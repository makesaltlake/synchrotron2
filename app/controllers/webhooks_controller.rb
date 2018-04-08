class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :require_stripe_token

  def require_stripe_token
    require_token 'stripe'
  end


  def stripe
    render json: {status: 'WIP'}
  end
end
