class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    render json: @user
  end

  def new
    #@user = User.new　＃APIでなければ、ここでビューを返す。
  end

  #POST/ sign_up
  def sign_up
    token = FirebaseToken.new(params[:token_id])
    firebase_project_id = 'droidsoftthird-2cc9b'#TODO プロジェクト名もAndroid側から取得できると良い。
    payload = token.verify(firebase_project_id)
    user_id = payload["user_id"]
    email = payload['email']
    if User.find_by(user_id: user_id)
      render json: { error: { messages: ["すでに登録されています"] } }, status: :unauthorized
    else
      create(user_id, email)
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
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
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params[:user].permit(:name, :email, :password, :password_confirmation)# おそらくここが間違っているからpostが通らない。
      #                             :age, :sexuality, :activityArea, :preference_id, :setting_id

    end

  private
  def create(user_id, email)
    @user = User.new(user_id: user_id, email: email)
    if @user.save
      log_in @user
      render json: @user, status: :created, location: @user
      # TODO 成功した時に何をモバイル側に返せば良いのかを確認する。
      # TODO 成功と共にAndroidの画面を切り替える。
    else
      render json: @user.errors, status: :unprocessable_entity
      #ここでエラーを返しているので、Android側ではメッセージを出して再度認証してもらうのが正解。
    end
  end

end
