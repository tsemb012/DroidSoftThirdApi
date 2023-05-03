class Group < ApplicationRecord
  #before_create :set_uuid
  has_many :participations
  has_many :users, through: :participations
  has_many :events

  scope :by_gender, ->(gender) { where(is_same_sexuality: false).or(where(group_host_gender: gender)) }
  scope :by_prefecture, ->(area_category, area_code) { where(prefecture_code: area_code) if area_category == 'prefecture' }
  scope :by_city, ->(area_category, area_code) { where(city_code: area_code) if area_category == 'city' }

  enum group_type: {
    seminar: 0, workshop: 1, mokumoku: 2,
    other_group_type: 99, none_group_type: -1
  }

  enum frequency_basis: {
    daily: 0, weekly: 1, monthly: 2,
    none_facility_basis: -1
  }

  enum facility_environment: {
    library: 0, cafe_restaurant: 1, rental_space: 2,
    co_working_space: 3, paid_study_space: 4, park: 5, online: 6,
    other_facility_environment: 99, none_facility_environment: -1
  }
end
