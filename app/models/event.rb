class Event < ApplicationRecord
  has_one :place
  belongs_to :group
  has_many :registrations, dependent: :destroy
  has_many :users, through: :registrations

  #eventのplaceをnull不可にする。
end
