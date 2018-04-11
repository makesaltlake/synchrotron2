ActiveAdmin.register Certification do
  permit_params :name
  # support for a :priority option is in master - this should be switched to use that once the next release is cut
  config.action_items.insert(0,
    ActiveAdmin::ActionItem.new(:view_recipients, only: :show) do
      link_to 'View Recipients', admin_certification_certification_recipients_path(resource)
    end,
    ActiveAdmin::ActionItem.new(:view_instructors, only: :show) do
      link_to 'View Instructors', admin_certification_certification_instructors_path(resource)
    end
  )
  #actions do |certification|
  #  link_to 'View Instructors', admin_certification_certification_instructors_path(certification)
  #end
end
