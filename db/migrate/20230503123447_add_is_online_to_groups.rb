class AddIsOnlineToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :is_online, :boolean
  end
end
