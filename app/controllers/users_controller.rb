class UsersController < ApplicationController

  def index
    render json: find_all_users
  end

  def show
    render json: find_user
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: find_user
    else
      # NOTE: 既存データとの重複もバリデーションエラーとしてここに入るが、 409 Conflict として分けるべき？
      render json: { message: user.errors.full_messages }, status: 400
    end
  end

  def update
    user = User.find_by_id(record_id)
    render json: { message: '対象のユーザーが存在していません。' }, status: 404 and return if user.blank?
    if user.update(user_params)
      render json: find_user
    else
      render json: { message: user.errors.full_messages }, status: 400
    end
  end

  def destroy
    user = User.find_by_id(record_id)
    render json: { message: '対象のユーザーが存在していません。' }, status: 404 and return if user.blank?
    User.deactivate(record_id)
    render json: find_user
  end

  private

    def user_params
      params.require(:user).permit(:uid, :name, :email, :password, :is_active)
    end

    def record_id
      params[:id]
    end

    def find_all_users
      User.all.to_json(secure)
    end

    def find_user
      User.find_by_id(record_id).to_json(secure)
    end

    def secure
      User.to_secure
    end

end
