class RemoveUnusedColumnsFromPlaces < ActiveRecord::Migration[6.0]
  def change
    remove_column :places, :place_type, :string
    remove_column :places, :global_code, :string
    remove_column :places, :compound_code, :string
  end
end
