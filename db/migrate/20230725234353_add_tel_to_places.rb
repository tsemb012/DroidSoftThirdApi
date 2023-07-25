class AddTelToPlaces < ActiveRecord::Migration[6.0]
  def change
    add_column :places, :tel, :string
  end
end
