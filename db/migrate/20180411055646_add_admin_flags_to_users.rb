class AddAdminFlagsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :site_admin, :boolean, default: false, null: false
    add_column :users, :shop_admin, :boolean, default: false, null: false
  end
end
