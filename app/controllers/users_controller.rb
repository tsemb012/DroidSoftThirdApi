class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

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
                      .merge(area: {prefecture: @user.prefecture, city: @user.city})
                      .merge(groups: @user.groups)
  end

  def new
    #@user = User.new　＃APIでなければ、ここでビューを返す。
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params) &
      @user.prefecture.update(prefecture_params) &
      @user.city.update(city_params)

      #&& @user.create_prefecture(prefecture_params) && @user.create_city(city_params)
      render json: { messages: "プロフィールを更新しました。" }, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
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
      params.require(:user).permit(:user_name, :age, :gender, :user_id, :user_image, :comment)# おそらくここが間違っているからpostが通らない。
    end

    def prefecture_params
      #params.require(:prefecture).permit(area: [ prefecture: [:prefecture_code, :name, :spell, capital: [:capital_name, :capital_spell, :capital_latitude, :capital_longitude]]])
      params[:area].require(:prefecture).permit(:prefecture_code, :name, :spell, :capital_name, :capital_spell, :capital_latitude, :capital_longitude)
    end

    def city_params
      params[:area].require(:city).permit(:city_code, :name, :spell, :latitude, :longitude)
    end

  def create(user_id, email)
    user = User.new(user_id: user_id, email: email)
    if user.save
      prefecture = user.create_prefecture
      city = user.create_city
      if prefecture.save & city.save
        log_in user
        render json: user, status: :created#, location: user
      end
      # TODO 成功した時に何をモバイル側に返せば良いのかを確認する。
      # TODO 成功と共にAndroidの画面を切り替える。
    else
      render json: user.errors, status: :unprocessable_entity
      #ここでエラーを返しているので、Android側ではメッセージを出して再度認証してもらうのが正解。
    end
  end

end
