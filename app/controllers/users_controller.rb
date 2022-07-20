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

  # POST /users
  def create #TODO ここでAuthenticity_tokenを入れてセキュリティを工場させる。
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
        # TODO 成功した時に何をモバイル側に返せば良いのかを確認する。
        # TODO 成功と共にAndroidの画面を切り替える。
    else
      render json: @user.errors, status: :unprocessable_entity
      #ここでエラーを返しているので、Android側ではメッセージを出して再度認証してもらうのが正解。
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
end
