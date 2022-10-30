class CreateCities < ActiveRecord::Migration[6.0]
  def change
    create_table :cities do |t|
      t.integer :city_code
      t.string :name
      t.string :spell
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
