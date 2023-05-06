class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy, :participate]

  def index
    groups = groups_with_pagination
    render json: groups
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

  def group_count_by_area
    group_counts_by_city = initialized_groups.all.group_by(&:city_code).map do |city_code, groups|
      city = City.find_by(city_code: city_code)
      {
        category: 'city',
        code: city_code,
        prefecture_name: Prefecture.find_by(prefecture_code: city.prefecture_code).name,
        city_name: city.name,
        latitude: city.latitude,
        longitude: city.longitude,
        group_count: groups.size
      }
    end

    group_counts_by_prefecture = initialized_groups.all.group_by(&:prefecture_code).map do |prefecture_code, groups|
      prefecture = Prefecture.find_by(prefecture_code: prefecture_code)
      {
        category: 'prefecture',
        code: prefecture_code,
        prefecture_name: prefecture.name,
        city_name: nil,
        latitude: prefecture.capital_latitude,
        longitude: prefecture.capital_longitude,
        group_count: groups.size
      }
    end
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
      :max_number, :is_same_sexuality, { group_types: [] }, { facility_environments: [] }, :frequency_basis)
  end

  def groups_with_pagination

    #initialized_groups
    groups = initialized_groups
    #groups = filtered_groups(initialized_groups)

    groups.page(params[:page]).per(5).map { |group| group_with_location(group) }
  end

=begin
  def filtered_groups(initialized_groups)
    initialized_groups.tap do |groups|
      groups.where(prefecture_code: params[:area_code]) if params[:area_category] == 'prefecture' && params[:area_code]
      groups.where(city_code: params[:area_code]) if params[:area_category] == 'city' && params[:area_code]
      groups.where(group_type: params[:group_types]) if params[:group_types]
      groups.where(facility_environment: params[:facility_environments]) if params[:facility_environments]
      groups.where(frequency_basis: params[:frequency_basis]) if params[:frequency_basis]
    end
  end
=end

  def all_groups
    Group.all.map { |group| group_with_location(group) }
  end

  def group_with_location(group)
    group.as_json.merge(
      {
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
    groups = Group.joins("LEFT JOIN participations ON groups.id = participations.group_id")
                  .joins("LEFT JOIN users ON participations.user_id = users.id")
                  .where("max_age >= ?", user.age) # ここで年齢で絞り込みをかける
                  .where("min_age <= ?", user.age)
                  .group("groups.id")
                  .having("groups.max_number > COUNT(participations.id)") # ここで人数で絞り込みをかける
                  .where("(groups.is_same_sexuality = false) OR (users.gender = ? OR users.gender = 'no_answer')", user.gender) # TODO ここで性別で絞り込みをかける
                  .where.not("groups.id IN (?)", user.groups.ids) # ここで参加済みのグループを除外する

    groups = groups.where(prefecture_code: params[:area_code]) if params[:area_category] == 'prefecture' && params[:area_code]
    groups = groups.where(city_code: params[:area_code]) if params[:area_category] == 'city' && params[:area_code]
    groups = groups.where(group_type: params[:group_types]) if params[:group_types] && !params[:group_types].empty?
    groups = groups.where(facility_environment: params[:facility_environments]) if params[:facility_environments] && !params[:facility_environments].empty?
    groups = groups.where(frequency_basis: params[:frequency_basis]) if params[:frequency_basis]

    groups
  end
end

