class RemoveMinNumberFromGroups < ActiveRecord::Migration[6.0]
  def change
    remove_column :groups, :min_number, :integer
  end
end
