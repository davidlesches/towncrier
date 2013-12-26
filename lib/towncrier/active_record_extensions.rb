class ActiveRecord::Base

  after_create :broadcast_create_towncry
  after_update :broadcase_update_towncry

  def broadcast_create_towncry
    broadcast_towncry(:create)
  end

  def broadcase_update_towncry
    broadcast_towncry(:update)
  end

  def broadcast_towncry action
    info = { :class => self.class.name, :id => self.id, :action => action }
    ActiveSupport::Notifications.instrument('towncry', info)
  end

end
