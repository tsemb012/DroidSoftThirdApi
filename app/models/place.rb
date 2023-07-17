class Place < ApplicationRecord
  belongs_to :event

  CATEGORIES = {
    cafe: '0115',
    park: '0305007'
  }


end
