ActiveAdmin.register CertificationRecipient do
  belongs_to :certification
  permit_params :certification_id, :user_id, :revoked_at, :revoked_reason
end
