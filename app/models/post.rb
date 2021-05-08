class Post < ApplicationRecord
  belongs_to :user

  attribute :children, :array, default: []

  # Not null
  with_options presence: true do
    validates :parent_id
    validates :title
    validates :text
  end

  # Boolean only
  validates :is_deleted, inclusion: { in: [ true, false ] }

  scope :select_posts_with_users, -> { select("posts.*, users.uid, users.name") }
  scope :join_users, -> { joins(:user) }
  scope :by_user_id, -> (user_id) { where(user_id: user_id) }
  scope :by_parent_id, -> (parent_id) { where(parent_id: parent_id) }
  scope :with_visible, -> { where(is_deleted: false) } 
  scope :only_parents, -> { where('posts.id = parent_id') }
  scope :only_children, -> { where('posts.id != parent_id') }

  class << self

    def all_with_reply
      children = select_all_visible_children.group_by { |x| x.parent_id }
      select_all_visible_parents&.each { |x| x.children = children[x.id] || [] } || []
    end

    def find_by_uid(uid)
      user_id = User.find_by_uid(uid)&.id
      user_id ? self.by_user_id(user_id).with_visible : nil
    end

    def find_by_title(title)
      self.where('title LIKE ?', "%#{escape(title)}%").with_visible
    end

    def find_by_text(text)
      self.where('text LIKE ?', "%#{escape(text)}%").with_visible
    end

    def find_children_by_parent_id(parent_id)
      self.with_visible.only_children.join_users.select_posts_with_users.by_parent_id(parent_id)
    end

    def logical_delete(id)
      post = Post.find_by_id(id)
      return nil if post.blank?

      post.update(is_deleted: true)
      logical_delete_children(id)

      post
    end

    private

      def escape(str)
        str.gsub(/([%_])/){ "\\#{$1}" }
      end

      def select_all_visible_parents
        self.with_visible.only_parents.join_users.select_posts_with_users
      end
  
      def select_all_visible_children
        self.with_visible.only_children.join_users.select_posts_with_users
      end

      def logical_delete_children(parent_id)
        find_children_by_parent_id(parent_id).each { |post| post.update(is_deleted: true) }
      end

  end

end
