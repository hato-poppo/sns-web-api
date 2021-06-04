class PostsController < ApplicationController

  # TODO: 操作前に権限チェックを行う

  def index
    posts = Post.all_with_reply&.to_json(secure)
    response_success(posts)
  end

  def show
    # user = User.find_by_id(record_id)&.to_json(secure)
    # user ? response_success(user) : response_not_found(not_found_message)
  end

  def create
    # user = User.new(user_params)
    # user.save ? response_success(user.to_json(secure)) : response_bad_request(user.errors.full_messages)
  end

  def update
    # user = User.find_by_id(record_id)
    # response_not_found(not_found_message) and return if user.blank?
    # user.update(user_params) ? response_success(user&.to_json(secure)) : response_bad_request(user.errors.full_messages)
  end

  def destroy
    # response_not_found(not_found_message) and return if User.find_by_id(record_id).blank?
    # response_success(User.deactivate(record_id)&.to_json(secure))
  end

  private

    def post_params
      # params.require(:user).permit(:uid, :name, :email, :password, :role_id, :is_active)
    end

    def secure
      Post.to_secure
    end


end
