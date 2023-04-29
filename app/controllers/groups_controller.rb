class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy, :participate]

  def index
    groups = groups_with_pagination
    render json: groups
  end

    # TODO finderクラスに切り分けてしまう　→　複雑系
    # TODO スコープ

    # 新しいコントローラーを分ける。別のコントロらー

  def show
    render json: @group.as_json.merge(
      {
        members: @group.users,
        prefecture: Prefecture.find_by(prefecture_code: @group.prefecture_code).name,
        city: City.find_by(city_code: @group.city_code).name
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
    group_counts_by_city = Group.all.group_by(&:city_code).map do |city_code, groups|
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

    group_counts_by_prefecture = Group.all.group_by(&:prefecture_code).map do |prefecture_code, groups|
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
    params.require(:group).permit(
      :host_id, :image_url, :name, :introduction, :group_type, :prefecture_code, :city_code,
      :facility_environment, :frequency_basis, :frequency_times, :max_age, :min_age,
      :max_number, :is_same_sexuality
    )
  end

  def groups_with_pagination
    #AndroidでPaginationの実装を使用している以上これで問題ないが、web, iosなどを今後使う場合は問題になる。
    user = User.find_by(user_id: params[:user_id])
    groups = if params[:area_category] == 'prefecture' && params[:area_code]
               Group.where(prefecture_code: params[:area_code])
             elsif params[:area_category] == 'city' && params[:area_code]
               Group.where(city_code: params[:area_code])
             else
               Group.all
             end
    filtered_groups = Group.where(id: groups.map(&:id))
                           .where("max_number > ?", User.group(:group_id).where(groups: {id: Group.ids}).count)
                           .where("max_age >= ?", user.age)
                           .where("min_age <= ?", user.age)
    #.by_gender(user.gender)

    filtered_groups.page(params[:page]).per(5).map { |group| group_with_location(group) }
  end

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
end

