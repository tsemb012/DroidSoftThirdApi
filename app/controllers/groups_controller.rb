class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy, :participate, :leave, :chat_group]

  def index
    groups = groups_with_pagination
    if groups.nil?
      render json: { error: "グループの取得に失敗しました。" }, status: :internal_server_error #TODO I18n.localeでローカライズする。
    else
      render json: groups
    end
  end

  def show
    render json: @group.as_json.merge(
      {
        members: @group.users,
        prefecture: Prefecture.find_by(prefecture_code: @group.prefecture_code)&.name,
        city: City.find_by(city_code: @group.city_code)&.name
      })
  end

  def participate
    user = User.find_by(user_id: params[:user_id])
    if user.groups.count > 20
      render json: { message: "参加可能なグループは最大20件です" }, status: :bad_request
    else if !@group.users.include?(user)
           @group.users << user
           render json: { message: "success" }, status: :created
         else
           render json: { message: "すでに参加しています" }, status: :bad_request
         end
    end
  end

  def leave
    user = User.find_by(user_id: params[:user_id])
    if @group.users.include?(user)
      @group.users.delete(user)
      render json: { message: "success" }, status: :ok
    else
      render json: { message: "グループのメンバーではありません" }, status: :bad_request
    end
  end

  def chat_group
    if @group
      render json: {
        group_id: @group.id,
        group_name: @group.name,
        host_id: @group.host_id,
        members: @group.users
      }
    else
      render json: { message: "グループが見つかりません" }, status: :not_found
    end
  end


  def create
    user = User.find_by(user_id: group_params[:host_id])
    if user.groups.count > 20
      render json: { message: "所属可能なグループは最大20件です" }, status: :bad_request
    else
      group = Group.new(group_params)
      if group.save
        group.users << user
        render json: { message: "success" }, status: :created
      else
        render json: group.errors, status: :unprocessable_entity
      end
    end
  end

  def group_count_by_area
    group_counts_by_city = initialized_groups.all.group_by(&:city_code).map do |city_code, groups|
      city = City.find_by(city_code: city_code)

      if city.nil?
        next
      end

      {
        category: 'city',
        code: city_code,
        prefecture_name: Prefecture.find_by(prefecture_code: city.prefecture_code).name,
        city_name: city.name,
        latitude: city.latitude,
        longitude: city.longitude,
        group_count: groups.size
      }
    end.compact # Remove nil elements from the array

    group_counts_by_prefecture = initialized_groups.all.group_by(&:prefecture_code).map do |prefecture_code, groups|
      prefecture = Prefecture.find_by(prefecture_code: prefecture_code)

      if prefecture.nil?
        next
      end

      {
        category: 'prefecture',
        code: prefecture_code,
        prefecture_name: prefecture.name,
        city_name: nil,
        latitude: prefecture.capital_latitude,
        longitude: prefecture.capital_longitude,
        group_count: groups.size
      }
    end.compact

    group_counts_by_area = group_counts_by_city + group_counts_by_prefecture
    render json: group_counts_by_area
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
    params.permit(
      :host_id, :image_url, :name, :introduction, :prefecture_code, :city_code, :is_online, :frequency_times, :max_age, :min_age,
      :max_number, :is_same_sexuality, :group_type, :facility_environment, :frequency_basis, :style)
  end

  def groups_with_pagination
    begin
      groups = initialized_groups.order(created_at: :desc).page(params[:page]).per(5)
                                 .map { |group| group_with_location_and_members(group) }
    rescue StandardError => e
      # エラー発生時の処理を記述します。以下はエラーメッセージをログに出力する一例です。
      Rails.logger.error "Failed to fetch groups: #{e.message}"
      return nil
    end
    groups
  end

  def all_groups
    Group.all.map { |group| group_with_location_and_members(group) }
  end

  def group_with_location_and_members(group)
    group.as_json.merge(
      {
        members: group.users,
        prefecture: Prefecture.find_by(prefecture_code: group.prefecture_code).name,
        city: City.find_by(city_code: group.city_code).name
      }
    )
  end

  def group_member_count(group_id)
    Participation.where(group_id: group_id).count
  end

  def initialized_groups
    user = User.find_by(user_id: params[:user_id])
    allow_max_number_group_show = params[:allow_max_number_group_show] || true

    groups = Group.joins("LEFT JOIN participations ON groups.id = participations.group_id")
                  .joins("LEFT JOIN users ON participations.user_id = users.id")
                  .where("max_age >= ?", user.age)
                  .where("min_age <= ?", user.age)
                  .where("(groups.is_same_sexuality = false) OR (users.gender = ? OR users.gender = 'no_answer')", user.gender)
                  .where.not("groups.id IN (?)", user.groups.ids)

    if allow_max_number_group_show == true
      groups = groups.group("groups.id")
    else
      groups = groups.group("groups.id").having("groups.max_number > COUNT(participations.id)")
    end

    groups = groups.where(prefecture_code: params[:area_code]) if params[:area_category] == 'prefecture' && params[:area_code]
    groups = groups.where(city_code: params[:area_code]) if params[:area_category] == 'city' && params[:area_code]
    groups = groups.where(group_type: params[:group_type]) if params[:group_type]
    groups = groups.where(facility_environment: params[:facility_environments]) if params[:facility_environments] && !params[:facility_environments].empty?
    groups = groups.where(frequency_basis: params[:frequency_basis]) if params[:frequency_basis]
    groups = groups.where(style: params[:style]) if params[:style]
    groups
  end
end

