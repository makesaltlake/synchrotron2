module WebhooksAndThings
  @stripe_event_handlers = {}

  def self.on_stripe_event(name, &block)
    @stripe_event_handlers[name] = block
  end

  def self.process_stripe_event(data)
    send_later_enqueue_args(:process_stripe_event_now, {strand: 'reports'}, data)
  end

  def self.process_stripe_event_now(data)
    if @stripe_event_handlers.key?(data['type'])
      Rails.logger.info("handling webhook event #{data['type']}")
      @stripe_event_handlers[data['type']].call(data)
    else
      Rails.logger.info("ignoring webhook event #{data['type']}")
    end
  end

  on_stripe_event 'customer.subscription.created' do |data|
    Rails.logger.info('new customer yay')
  end

  on_stripe_event 'customer.subscription.deleted' do |data|
    Rails.logger.info('deleted customer yay')
  end
end
