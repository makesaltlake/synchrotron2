class WebhooksController < ApplicationController
  def stripe
    render json: {status: 'WIP'}
  end
end
