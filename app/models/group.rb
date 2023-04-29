class Group < ApplicationRecord
  #before_create :set_uuid
  has_many :participations
  has_many :users, through: :participations
  has_many :events

  scope :by_gender, ->(gender) { where(is_same_sexuality: false).or(where(group_host_gender: gender)) }
  scope :by_prefecture, ->(area_category, area_code) { where(prefecture_code: area_code) if area_category == 'prefecture' }
  scope :by_city, ->(area_category, area_code) { where(city_code: area_code) if area_category == 'city' }
end
