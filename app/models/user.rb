class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable

  has_many :certification_instructors
  has_many :certification_recipients

  def display_name
    "##{id}: #{email}"
  end
end
