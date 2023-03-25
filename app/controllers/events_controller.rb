require 'securerandom'

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :update, :destroy, :register, :unregister]

  def index
    registrations = Registration.where(event_id: params[:event_id])
    user = User.find_by(user_id: params[:user_id])
    events = Event.joins(:group => :participations).where('participations.user_id = ?', user.id).map do |event| #whereで絞るためにjoinsを使ってテーブルを結合していく。
      event.as_json.merge(
        {
          group_name: event.group.name,
          place_name: event.place&.name || "" ,
          registered_user_ids: registrations&.pluck(:user_id) || []
        }
      )
    end
    render json: events
  end

  def show
    render json: @event.as_json.merge(
      {
        group_id: @event.group.id,
        group_name: @event.group.name,
        place: @event.place.as_json,
        registered_user_ids: @event.registrations.pluck(:user_id).map { |id| User.find(id).user_id }, # registrationを
      }
    )
  end

  def create
    event = Event.new(event_params)
    event.video_chat_room_id = SecureRandom.uuid

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

  def register
    user_id = params[:user_id]
    user = User.find_by(user_id: user_id)

    if user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    if @event.users.include?(user)
      render json: { error: 'User already registered' }, status: :unprocessable_entity
    else
      @event.users << user
      render json: { message: 'User successfully registered' }, status: :ok
    end
  end

  def unregister
    user_id = params[:user_id]
    user = User.find_by(user_id: user_id)

    if user.nil?
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    if @event.users.include?(user)
      @event.users.delete(user)
      render json: { message: 'User successfully unregistered' }, status: :ok
    else
      render json: { error: 'User not registered' }, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:host_id, :name, :comment, :date, :start_time, :end_time, :group_id, :video_chat_room_id)
  end

  def place_params
    params.require(:place).permit(:name, :address, :latitude, :longitude, :place_id, :place_type, :global_code, :compound_code, :url, :memo)
  end
end
