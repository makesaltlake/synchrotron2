class ReportsController < ApplicationController
  before_action :require_report_token

  def require_report_token
    require_token 'report'
  end

  def membership_delta
    render json: {status: 'WIP'}
  end
end
