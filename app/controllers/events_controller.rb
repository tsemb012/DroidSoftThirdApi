class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy, :participate]

  # POST /events
  def create
    event = Event.new(event_params)
    place = Place.new(place_params)

    if place.valid? && event.valid?
      ActiveRecord::Base.transaction do
        place.save!
        event.place = place
        event.save!
        event.users << User.find_by(user_id: group[:user_id])
        event.registrations.build(user_id: user.id)
        group = Group.find_by(group_id: group[:group_id])
        group.events << event
      end
      render json: { message: "success" }, status: :created
    else
      render json: { message: "failure", errors: place.errors.merge(event.errors) }, status: :unprocessable_entity
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
    params.require(:place).permit(:name, :address, :latitude, :longitude, :place_id, :type, :global_code, :compound_code, :url, :memo)
  end
end
