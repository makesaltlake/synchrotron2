module StripeCacheUpdater
  def self.update_cache
    TransactionRetry.transaction do
      existing_ids = Set.new(CachedSubscription.all.pluck(:id))

      Stripe::Subscription.list(status: 'all', expand: ['data.customer']).auto_paging_each do |subscription|
        puts "processing #{subscription.id}"
        cached_subscription = CachedSubscription.find_by_stripe_id(subscription.id)
        if cached_subscription
          existing_ids.delete(cached_subscription.id)
        else
          cached_subscription = CachedSubscription.new(stripe_id: subscription.id)
        end

        cached_subscription.customer_description = subscription.customer.description
        cached_subscription.customer_email = subscription.customer.email
        cached_subscription.status = subscription.status
        cached_subscription.canceled_at = subscription.canceled_at && Time.at(subscription.canceled_at)
        cached_subscription.ended_at = subscription.ended_at && Time.at(subscription.ended_at)
        cached_subscription.start = subscription.start && Time.at(subscription.start)

        cached_subscription.save! if cached_subscription.changed?
      end

      existing_ids.each_slice(50) do |ids_to_delete|
        Rails.logger.info("subscriptions were deleted, removing: #{ids_to_delete}")
        CachedSubscription.destroy(ids_to_delete)
      end
    end
  end
end
