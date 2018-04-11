ActiveAdmin.register CertificationInstructor do
  belongs_to :certification
  permit_params :certification_id, :user_id
end
