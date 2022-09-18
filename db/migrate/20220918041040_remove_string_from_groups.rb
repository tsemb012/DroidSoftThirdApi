class RemoveStringFromGroups < ActiveRecord::Migration[6.0]
  def change
    remove_column :groups, :string, :string
  end
end
