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
                            city: Prefecture.find_by(city_code: @user.city_code),
                          },
                          groups: @user.groups,
                          events: @user.events,
                        }
                      )
  end

  def new
    #@user = User.new　＃APIでなければ、ここでビューを返す。
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)#prefecture_codeとcity_codeを入れるようにする。

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
      params.require(:user).permit(:user_name, :age, :gender, :user_id, :user_image, :comment, :prefecture_code, :city_code)# おそらくここが間違っているからpostが通らない。
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

end
