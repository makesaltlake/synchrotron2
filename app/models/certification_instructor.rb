class CertificationInstructor < ApplicationRecord
  belongs_to :user
  belongs_to :certification

  validates :user, uniqueness: {scope: :certification, message: 'is already an instructor for this certification'}

  def display_name
    user.short_display_name
  end
end
