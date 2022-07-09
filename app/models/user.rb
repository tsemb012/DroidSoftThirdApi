class User < ApplicationRecord
  belongs_to :preference
  belongs_to :setting
end
