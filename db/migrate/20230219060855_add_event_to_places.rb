class AddEventToPlaces < ActiveRecord::Migration[6.0]
  def change
    add_reference :places, :event, null: true, foreign_key: true
  end
end
