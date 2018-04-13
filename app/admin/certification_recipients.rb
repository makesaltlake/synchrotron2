ActiveAdmin.register CertificationRecipient do
  actions :all, except: [:edit, :update, :delete, :destroy]
  belongs_to :certification
  permit_params :certification_id, :user_id, :revoked_at, :revoked_reason

  config.clear_action_items!
  action_item :new, only: :index do
    link_to 'Add Recipient', new_admin_certification_certification_recipient_path
  end

  scope :active, default: true
  scope :revoked
  scope :all

  index do
    selectable_column
    # id_column # Hidden in the interest of simplicity. I may come to regret this.
    column :user
    column :certified_at
    column :certified_by
    column :status do |certification|
      if certification.revoked_at
        status_tag 'revoked', class: 'red'
      else
        status_tag 'active', class: 'green'
      end
    end
    actions defaults: false do |certification_recipient|
      span link_to 'Revoke', revoke_admin_certification_certification_recipient_path(certification_recipient.certification, certification_recipient), class: 'member_link'
    end
  end

  form do |f|
    f.inputs do
      f.input :user
    end

    f.actions do
      f.action :submit, label: 'Add Recipient'
      f.action :cancel, label: 'Cancel'
    end
  end

  before_create do |certification_recipient|
    certification_recipient.certified_by = current_user
    certification_recipient.certified_at = Time.now
  end

  member_action :revoke, method: [:get, :post] do
    certification_recipient = CertificationRecipient.find(params[:id])
    authorize! :revoke, certification_recipient

    if request.post?
      certification_recipient.revoke!(current_user, params[:reason])

      flash[:notice] = "#{certification_recipient.user.short_display_name}'s certification on #{certification_recipient.certification.name} has been revoked."
      redirect_to admin_certifications_certification_recipients_path(certification_recipient.certification)
    end
  end
end
