class AddPlaceToEvents < ActiveRecord::Migration[6.0]
  def change
    add_reference :events, :place, null: false, foreign_key: true
  end
end
