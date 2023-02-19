class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy, :participate]

  # POST /events
  def create
    event = Event.new(event_params)
    place = Place.new(place_params)
    event.save!
    event.place = place
    if place.save!
      ActiveRecord::Base.transaction do
        event.place = place
        event.users << User.find_by(user_id: event[:host_id])
        group = Group.find event[:group_id]
        group.events << event
      end
      render json: { message: "success" }, status: :created
    else
      render json: { message: "failure", errors: event.errors.full_messages + place.errors.full_messages }, status: 400
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def event_params
    params.require(:event).permit(:host_id, :name, :comment, :date, :start_time, :end_time, :place_id, :group_id)
  end

  def place_params
    params.require(:place).permit(:name, :address, :latitude, :longitude, :place_id, :place_type, :global_code, :compound_code, :url, :memo)
  end
end
