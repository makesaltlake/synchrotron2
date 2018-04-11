class Certification < ApplicationRecord
  has_many :certification_instructors
  has_many :certification_recipients
end
