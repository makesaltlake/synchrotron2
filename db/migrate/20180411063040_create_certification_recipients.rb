class CreateCertificationRecipients < ActiveRecord::Migration[5.1]
  def change
    create_table :certification_recipients do |t|
      t.references :certification, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.datetime :certified_at, index: true
      t.datetime :revoked_at
      t.text :revoked_reason

      t.timestamps
    end

    # only one active certification recipient per user+certification combination, but they can have as many revoked
    # ones as they want (although at some point you'd start to question the certifier's sanity...)
    add_index :certification_recipients, [:certification_id, :user_id], unique: true, where: 'revoked_at is null', name: 'index_certification_recipients_on_certification_id_and_user_id'
  end
end
