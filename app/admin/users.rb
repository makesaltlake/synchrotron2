ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :site_admin, :shop_admin

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :site_admin
    column :shop_admin
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :site_admin
  filter :shop_admin
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :site_admin
      f.input :shop_admin
    end
    f.actions
  end

  # allow users to be updated without also updating their password
  controller do
    def update
      if params[:user][:password].blank?
        %w(password password_confirmation).each { |p| params[:user].delete(p) }
      end
      super
    end
  end
end
