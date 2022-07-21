module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す（いる場合） #ログイン後にいつでもここからユーザーデータを取得できるようにする。
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id]) #current_userが空ならば、DBにアクセスする。
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す　#ログイン中であれば、モバイル側ではログイン処理をスキップするということができるかも
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
