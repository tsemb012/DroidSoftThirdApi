class Event < ApplicationRecord
  has_one :place
  belongs_to :group
end
