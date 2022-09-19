class RenameTypeColumnToGroups < ActiveRecord::Migration[6.0]
  def change
    rename_column :groups, :type, :group_type
  end
end

