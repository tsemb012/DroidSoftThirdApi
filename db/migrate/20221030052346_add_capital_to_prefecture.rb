class AddCapitalToPrefecture < ActiveRecord::Migration[6.0]
  def change
    add_column :prefectures, :capital_name, :string
    add_column :prefectures, :capital_spell, :string
    add_column :prefectures, :capital_latitude, :float
    add_column :prefectures, :capital_longitude, :float
  end
end
