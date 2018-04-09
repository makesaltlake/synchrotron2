class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :require_stripe_token
  wrap_parameters format: []

  def require_stripe_token
    require_token 'stripe'
  end


  def stripe
    WebhooksAndThings.process_stripe_event(JSON.parse(request.body.read))
    render plain: 'ok'
  end
end
