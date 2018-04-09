class CreateCachedSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :cached_subscriptions do |t|
      t.string :stripe_id
      t.string :customer_description
      t.string :customer_email
      t.string :status
      t.datetime :canceled_at
      t.datetime :ended_at
      t.datetime :start

      t.timestamps
    end
  end
end
