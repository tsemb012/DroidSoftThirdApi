class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :destroy, :participate]

  # GET /groups
  def index #TODO 条件分岐をわかりやすくする。
    if (page = params[:page])#指定されたページのアイテムを取得する
      groups = Group.page(page).per(4)
      render json: groups
    else
      if (user_id = params[:user_id])#指定されたユーザーの参加しているグループを取得する
        joined_group = Group.all.select{|group| group.users.find_by(user_id: user_id)}
        render json: joined_group
      else
        render json: Group.all #全てのグループを取得する
      end
    end
  end

  # GET /groups/1
  def show
    group = Group.find(params[:id])
    render json: group.as_json.merge({members: group.users})
  end

  #PATCH /groups/1
  def participate
    group = Group.find(params[:id])
    user = User.find_by user_id: params[:user_id]
    if !group.users.include?(user)
      group.users << user
      render json: { message: "success" }, status: :created
    else
      render json: { messages: "すでに参加しています" }, status: 400 # 適切なステータスに変更する
    end
  end

  # POST /groups
  def create
    group = Group.new
    group.update(group_params)
    if group.save
      user = User.find_by user_id: group[:host_id]
      group.users << user
      render json: { message: "success" }, status: :created
    else
      render json: group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1
  def update
    if @group.update(group_params)
      render json: @group
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /groups/1
  def destroy
    @group.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def group_params
      params.require(:group).permit(:host_id, :image_url, :name, :introduction, :group_type, :prefecture, :city, :facility_environment, :frequency_basis, :frequency_times, :max_age, :min_age, :max_number, :min_number, :is_same_sexuality)
    end
end
