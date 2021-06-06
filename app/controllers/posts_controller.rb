class PostsController < ApplicationController

  # TODO: 操作前に権限チェックを行う

  def index
    posts = Post.all_with_reply&.to_json(secure)
    response_success(posts)
  end

  def show
    post = Post.find_by_id_with_children(record_id)&.to_json(secure)
    post ? response_success(post) : response_not_found(not_found_message)
  end

  def create
    response_unprocessable_entity('投稿ユーザーが存在していません。') and return if post_user_not_exist?
    response_unprocessable_entity('親投稿が存在していません。') and return if parent_post_not_exist?
    post = Post.new(create_params)
    post.save ? response_success(post.to_json(secure)) : response_unprocessable_entity(post.errors.full_messages)
  end

  def update
    post = Post.find_by_id(record_id)
    response_not_found(not_found_message) and return if post.nil?
    post.update(update_params) ? response_success(post.to_json(secure)) : response_unprocessable_entity(post.errors.full_messages)
  end

  def destroy
    # response_not_found(not_found_message) and return if User.find_by_id(record_id).blank?
    # response_success(User.deactivate(record_id)&.to_json(secure))
  end

  private

    def create_params
      params.require(:post).permit(:parent_id, :user_id, :title, :text)
    end

    def update_params
      params.require(:post).permit(:title, :text)
    end

    def record_id
      params[:id]
    end

    def secure
      Post.to_secure
    end

    def not_found_message
      '対象の投稿が存在していません。'
    end

    def post_user_not_exist?
      user_id = params[:post][:user_id] # ここの取り方をもっといい感じにしたい
      User.find_by_id(user_id).nil?
    end

    def parent_post_not_exist?
      parent_id = params[:post][:parent_id] # ここの取り方をもっといい感じにしたい
      parent_id.nil?.! && Post.find_by_id(parent_id).nil?
    end

end
