class AddHostIdToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :host_id, :string
  end
end
