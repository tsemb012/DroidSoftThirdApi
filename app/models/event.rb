class Event < ApplicationRecord
  has_one :place
  belongs_to :group
  has_many :registrations, dependent: :destroy
  has_many :users, through: :registrations

  STATUSES = {
    before_registration: "before_registration",
    after_registration_before_event: "after_registration_before_event",
    after_registration_during_event: "after_registration_during_event",
    after_event: "after_event"
  }.freeze

  def status_for(user)
    if !registrations.pluck(:user_id).include?(user.id)
      STATUSES[:before_registration]
    elsif registrations.pluck(:user_id).include?(user.id) && start_date_time > DateTime.now
      STATUSES[:after_registration_before_event]
    elsif registrations.pluck(:user_id).include?(user.id) && start_date_time <= DateTime.now && end_date_time >= DateTime.now
      STATUSES[:after_registration_during_event]
    elsif end_date_time < DateTime.now
      STATUSES[:after_event]
    end
  end

end
