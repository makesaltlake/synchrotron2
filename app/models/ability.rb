class Ability
  include CanCan::Ability

  def initialize(user)
    # let everyone do everything for now
    can :manage, :all
  end
end
