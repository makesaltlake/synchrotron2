class CertificationRecipient < ApplicationRecord
  belongs_to :user
  belongs_to :certification
  belongs_to :certified_by, class_name: 'User'
  belongs_to :revoked_by, class_name: 'User'

  scope :active, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  def display_name
    user.short_display_name
  end

  def revoke!(revoked_by, revoked_reason)
    self.revoked_by = revoked_by
    self.revoked_reason = reason
    self.save!
  end
end
