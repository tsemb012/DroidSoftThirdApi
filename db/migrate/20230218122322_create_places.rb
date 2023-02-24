class CreatePlaces < ActiveRecord::Migration[6.0]
  def change
    create_table :places do |t|
      t.string :name
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :place_id
      t.string :type
      t.string :global_code
      t.string :compound_code
      t.string :url
      t.text :memo

      t.timestamps
    end
  end
end
