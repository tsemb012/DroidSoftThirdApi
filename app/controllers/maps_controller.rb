class MapsController < ApplicationController
  def show
    @map = Map.find(params[:id])
    #どこにコードを記述すれば良いのか？
  end
end
