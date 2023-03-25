class AddVideoChatRoomIdToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :video_chat_room_id, :string
  end
end
