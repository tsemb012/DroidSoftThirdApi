class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy, :participate]

  def index
    if params[:page] # 指定されたページのアイテムを取得する
      groups = Group.page(params[:page]).per(4)
    elsif params[:user_id] # 指定されたユーザーの参加しているグループを取得する
      groups = Group.joins(:users).where(users: { user_id: params[:user_id] })
    else
      groups = Group.all # 全てのグループを取得する
    end
    render json: groups
  end

  def show
    render json: @group.as_json.merge({ members: @group.users })
  end

  def participate
    user = User.find_by(user_id: params[:user_id])
    if !@group.users.include?(user)
      @group.users << user
      render json: { message: "success" }, status: :created
    else
      render json: { message: "すでに参加しています" }, status: :bad_request
    end
  end

  def create
    group = Group.new(group_params)
    if group.save
      user = User.find_by(user_id: group.host_id)
      group.users << user
      render json: { message: "success" }, status: :created
    else
      render json: group.errors, status: :unprocessable_entity
    end
  end

  def show_group_locations
    groups = Group.all
    render json: groups.map { |group| group.as_json.merge({ place: group.place }) }
  end

  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(
      :host_id, :image_url, :name, :introduction, :group_type, :prefecture_code, :city_code,
      :facility_environment, :frequency_basis, :frequency_times, :max_age, :min_age,
      :max_number, :min_number, :is_same_sexuality
    )
  end
end
