class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  #TODO リファクタリング。ChatGPTだとエラー
  #POST/ sign_up
  def sign_up
    user_id = params[:user_id]
    if User.find_by(user_id: user_id)
      render json: { error: { messages: ["すでに登録されています"] } }, status: :unauthorized
    else
      create(user_id, self.email)
    end
  end

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/1
  def show #よりDBに負荷がかからないようにリファクタをする。
    render json: @user.as_json
                      .merge(
                        {
                          area: {
                            prefecture: Prefecture.find_by(prefecture_code: @user.prefecture_code),
                            city: City.find_by(city_code: @user.city_code),
                          },
                          groups: @user.groups.map do |group|
                            group.as_json.merge(
                              {
                                prefecture: Prefecture.find_by(prefecture_code: group.prefecture_code)&.name,
                                city: City.find_by(city_code: group.city_code)&.name
                              }
                            )
                          end,
                          events: @user.events,
                        }
                      )
  end

  # GET /users/1/groups
  def show_joined_groups
    groups = Group.joins(:users).where(users: { user_id: params[:user_id] }).map { |group| group_with_location(group) }
    render json: groups
  end

  # GET /users/1/groups/ids
  def show_joined_group_ids
    group_ids = Group.joins(:users).where(users: { user_id: params[:user_id] }).map { |group| group.id }
    render json: group_ids
  end

  def new
    #@user = User.new　＃APIでなければ、ここでビューを返す。
  end

  # PATCH/PUT /users/1
  def update
    begin
      User.transaction do
        update_user_with_date(user_params)
        if @user.save
          render json: { messages: "プロフィールを更新しました。" }, status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end
    rescue => e
      render json: { errors: e.message }, status: :unprocessable_entity
    end
  end


  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(user_id: params[:user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:user_name, :birthday, :gender, :user_id, :user_image, :comment, :prefecture_code, :city_code)# おそらくここが間違っているからpostが通らない。
    end

  def create(user_id, email)
    user = User.new(user_id: user_id, email: email)
    if user.save
      log_in user
      render json: user, status: :created#, location: user
      # TODO 成功した時に何をモバイル側に返せば良いのかを確認する。
      # TODO 成功と共にAndroidの画面を切り替える。
    else
      render json: user.errors, status: :unprocessable_entity
      #ここでエラーを返しているので、Android側ではメッセージを出して再度認証してもらうのが正解。
    end
  end

  def group_with_location(group)
    group.as_json.merge(
      {
        prefecture: Prefecture.find_by(prefecture_code: group.prefecture_code)&.name,
        city: City.find_by(city_code: group.city_code)&.name
      }
    )
  end

  def update_user_with_date(params)
    @user.assign_attributes(params.except(:birthday))
    @user.birthday = Date.parse(params[:birthday]) if params[:birthday].present?
  end

end
