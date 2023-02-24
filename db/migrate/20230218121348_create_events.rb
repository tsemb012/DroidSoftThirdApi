class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :host_id
      t.string :name
      t.string :comment
      t.string :date
      t.string :start_time
      t.string :end_time

      t.timestamps
    end
  end
end
