ActiveAdmin.register CertificationInstructor do
  actions :all, except: [:edit, :update]
  belongs_to :certification
  permit_params :certification_id, :user_id

  config.clear_action_items!
  action_item :new, only: :index do
    link_to 'Add Instructor', new_admin_certification_certification_instructor_path
  end

  index do
    selectable_column
    # id_column # Hidden in the interest of simplicity. I may come to regret this.
    column :user
    column 'Added At', :created_at
    actions defaults: false do |certification_instructor|
      item 'Remove', resource_path(certification_instructor), class: "delete_link member_link",
              method: :delete, data: {confirm: "Are you sure you want to remove #{certification_instructor.user.short_display_name} as an instructor for this certification?"}
    end
  end

  form do |f|
    f.inputs do
      f.input :user
    end

    f.actions do
      f.action :submit, label: 'Add Instructor'
      f.action :cancel, label: 'Cancel'
    end
  end
end
