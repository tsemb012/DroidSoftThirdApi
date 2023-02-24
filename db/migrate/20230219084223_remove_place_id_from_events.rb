class RemovePlaceIdFromEvents < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :events, :places
    remove_column :events, :place_id
  end
end
