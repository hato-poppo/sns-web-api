class UsersController < ApplicationController

  def index
    response_success(User.all&.to_json(secure))
  end

  def show
    user = User.find_by_id(record_id)&.to_json(secure)
    user ? response_success(user) : response_not_found(not_found_message)
  end

  def create
    user = User.new(user_params)
    # NOTE: 既存データとの重複もバリデーションエラーとして`400 Bad Request`に入るが、`409 Conflict`として分けるべき？
    user.save ? response_success(user.to_json(secure)) : response_bad_request(user.errors.full_messages)
  end

  def update
    user = User.find_by_id(record_id)
    response_not_found(not_found_message) and return if user.blank?
    user.update(user_params) ? response_success(user&.to_json(secure)) : response_bad_request(user.errors.full_messages)
  end

  def destroy
    response_not_found(not_found_message) and return if User.find_by_id(record_id).blank?
    response_success(User.deactivate(record_id)&.to_json(secure))
  end

  private

    def user_params
      params.require(:user).permit(:uid, :name, :email, :password, :role_id, :is_active)
    end

    def record_id
      params[:id]
    end

    def secure
      User.to_secure
    end

    def not_found_message
      '対象のユーザーが存在していません。'
    end

end
