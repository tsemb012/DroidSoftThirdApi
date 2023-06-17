class AddStyleToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :style, :integer
  end
end
