require 'securerandom'

class EventsController < ApplicationController
  before_action :set_event, only: %i[show update destroy register unregister]
  before_action :set_user, only: %i[index register unregister]

  def index
    events = Event.joins(group: :participations)
                  .where(participations: { user_id: @user.id })
                  .where(group_id: params[:group_id].presence)
                  .includes(:group, :place, :registrations)
                  .map { |event| event_data(event) }
    render json: events
  end

  def show
    render json: event_data(@event).merge(place: @event.place.as_json)
  end


  def create
    event = build_event_with_dates(event_params)
    event.video_chat_room_id = SecureRandom.uuid

    if params[:place].present?
      place = Place.new(place_params)
      event.place = place
    end

    save_event_with_transaction(event)

    render json: { message: "success" }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { message: "failure", errors: event.errors.full_messages + place&.errors&.full_messages.to_a }, status: 400
  end

  def destroy
    @event.transaction do
      # 関連するregistrationsレコードを削除（必要に応じて）
      @event.registrations.destroy_all
      @event.destroy
    end
    render json: { message: "success" }, status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: { message: "failure", errors: @event.errors.full_messages }, status: 400
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

  def set_user
    @user = User.find_by(user_id: params[:user_id])
  end

  def event_data(event)
    {
      id: event.id,
      group_name: event.group.name,
      place_name: event.place&.name || "",
      registered_user_ids: event.registrations.pluck(:user_id)
    }
  end

  def event_params
    params.require(:event).permit(:host_id, :name, :comment, :date, :start_date_time, :end_date_time, :group_id, :video_chat_room_id)
  end

  def place_params
    params.require(:place).permit(:name, :address, :latitude, :longitude, :place_id, :place_type, :global_code, :compound_code, :url, :memo)
  end

  def build_event_with_dates(params)
    event = Event.new(params.except(:start_date_time, :end_date_time))
    event.start_date_time = DateTime.parse(params[:start_date_time])
    event.end_date_time = DateTime.parse(params[:end_date_time])
    event
  end

  def save_event_with_transaction(event)
    ActiveRecord::Base.transaction do
      event.save!
      event.users << User.find_by(user_id: event.host_id)
      group = Group.find(event.group_id)
      group.events << event
    end
  end
end
