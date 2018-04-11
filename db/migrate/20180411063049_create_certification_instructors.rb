class CreateCertificationInstructors < ActiveRecord::Migration[5.1]
  def change
    create_table :certification_instructors do |t|
      t.references :certification, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps
    end

    # only one user+certification combo at a time
    add_index :certification_records, [:certification_id, :user_id], unique: true, name: 'index_certification_instructors_on_certification_id_and_user_id'
  end
end
