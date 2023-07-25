class AddYomiAndCategoryToPlaces < ActiveRecord::Migration[6.0]
  def change
    add_column :places, :yomi, :string
    add_column :places, :category, :string
  end
end
