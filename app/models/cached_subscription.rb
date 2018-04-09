class CachedSubscription < ApplicationRecord
  ACTIVE_SUBSCRIPTION_STATUSES = ['trialing', 'active', 'past_due', 'unpaid']
  CURRENT_SUBSCRIPTION_STATUSES = ['trialing', 'active']

  default_scope { order(start: :asc) }
  scope :active, -> { where(status: ACTIVE_SUBSCRIPTION_STATUSES) }
  scope :current, -> { where(status: CURRENT_SUBSCRIPTION_STATUSES) }
end
