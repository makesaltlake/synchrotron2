class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :read, ActiveAdmin::Page, name: 'Dashboard'

    if user.site_admin
      can :manage, :all
    end
  end
end
