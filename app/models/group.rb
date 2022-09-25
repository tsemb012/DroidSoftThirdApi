class Group < ApplicationRecord
  #before_create :set_uuid
  has_many :participations
  has_many :users, through: :participations

=begin
  private
    def set_uuid
      while self.id.blank? || User.find_by(id: self.id).present? do
        self.id = SecureRandom.uuid.
      end
    end
=end
end
