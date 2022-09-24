class User < ApplicationRecord
  #before_create :set_uuid
  has_many :participations
  has_many :groups, through: :participations

  before_save { self.email = email.downcase }
  self.primary_key = :user_id
  #validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }

  private
=begin
begin
  def set_uuid
    while self.id.blank? || User.find_by(id: self.id).present? do
      self.id = SecureRandom.uuid
    end
  end
end
=end
end
