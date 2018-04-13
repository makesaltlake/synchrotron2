ActiveAdmin.register Certification do
  actions :all, except: [:delete, :destroy]
  permit_params :name

  config.clear_action_items!
  action_item :view_recipients, only: :show do
    link_to 'View Recipients', admin_certification_certification_recipients_path(resource)
  end
  action_item :view_instructors, only: :show do
    link_to 'View Instructors', admin_certification_certification_instructors_path(resource)
  end
  action_item :edit, only: :show do
     link_to 'Edit', edit_admin_certification_path(certification)
  end

  index do
    selectable_column
    column :name, sortable: :name do |certification|
      link_to certification.name, admin_certification_path(certification)
    end
    actions defaults: false do |certification|
      span link_to 'View Recipients', admin_certification_certification_recipients_path(certification), class: 'member_link'
      span link_to 'View Instructors', admin_certification_certification_instructors_path(certification), class: 'member_link'
      span link_to 'Edit', edit_admin_certification_path(certification), class: 'member_link'
    end
  end

  show do
    attributes_table do
      row :name
    end
    panel "Instructors" do
      span link_to 'Test', 'https://google.com'
      table_for certification.certification_instructors do
        column :user
      end
    end
  end
end
