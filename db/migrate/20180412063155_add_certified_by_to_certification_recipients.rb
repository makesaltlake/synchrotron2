class AddCertifiedByToCertificationRecipients < ActiveRecord::Migration[5.1]
  def change
    add_reference :certification_recipients, :certified_by, references: :users, index: true
    add_foreign_key :certification_recipients, :users, column: :certified_by_id
  end
end
