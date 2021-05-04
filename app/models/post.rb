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

  scope :join_users, -> { joins(:user) }
  scope :by_user_id, -> (id) { where(user_id: id) }
  scope :with_visible, -> { where(is_deleted: false) } 
  scope :with_parents, -> { where('posts.id = parent_id') }
  scope :with_children, -> { where('posts.id != parent_id') }

  class << self

    def all_with_reply
      children = find_children
      find_parents&.each { |x| x.children = children[x.id] || [] } || []
    end

    def find_parents
      self.with_visible.with_parents.join_users.select("posts.*, users.uid, users.name")
    end

    def find_children
      self.with_visible.with_children.join_users.select("posts.*, users.uid, users.name").group_by { |x| x.parent_id }
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

    def logical_delete(id)
      post = Post.find_by_id(id)
      return nil if post.blank?

      post.update(is_deleted: true)
      post
    end

    private

      def escape(str)
        str.gsub(/([%_])/){ "\\#{$1}" }
      end

  end

end
