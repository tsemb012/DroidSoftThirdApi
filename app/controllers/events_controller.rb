class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy, :participate]

  def index
    user = User.find_by(user_id: params[:user_id])
    events = Event.joins(:group => :participations).where('participations.user_id = ?', user.id).map do |event|
      event.as_json.merge(
        {
          group_name: event.group.name,
          place_name: event.place&.name || "" ,
        }
      )
    end
    render json: events
  end

  def create
    event = Event.new(event_params)
    if params[:place].present?
      place = Place.new(place_params)
      event.place = place
    end
    ActiveRecord::Base.transaction do
      event.save!
      event.users << User.find_by(user_id: event.host_id)
      group = Group.find(event.group_id)
      group.events << event
    end

    render json: { message: "success" }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { message: "failure", errors: event.errors.full_messages + place.errors.full_messages }, status: 400
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:host_id, :name, :comment, :date, :start_time, :end_time, :group_id)
  end

  def place_params
    params.require(:place).permit(:name, :address, :latitude, :longitude, :place_id, :place_type, :global_code, :compound_code, :url, :memo)
  end
end
