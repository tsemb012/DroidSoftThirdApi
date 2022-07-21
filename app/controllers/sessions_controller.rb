class SessionsController < ApplicationController
  def new
    # APIでなければ、ここでビューを返す。
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      # 成功した場合、user情報を渡し、成功を伝える、
    else
      #エラーメッセージも作成する。モバイル側にエラーとメッセージを送るのか。あるいは通常のメッセージを送るのか？
    end
  end
  #値を送る側は右の形で送る。 { session: { password: "foobar", email: "user@example.com" } }

  def destroy
    log_out
  end
end
