class Post < ApplicationRecord
  belongs_to :user

  attribute :children, :array, default: []

  # Not null
  with_options presence: true do
    validates :title
    validates :text
  end

  # Boolean only
  validates :is_deleted, inclusion: { in: [ true, false ] }

  scope :select_posts, -> { select("posts.*") }
  scope :by_id, -> (id) { where(id: id) }
  scope :by_user_id, -> (user_id) { where(user_id: user_id) }
  scope :by_parent_id, -> (parent_id) { where(parent_id: parent_id) }
  scope :with_visible, -> { where(is_deleted: false) }
  scope :only_parents, -> { where(parent_id: nil) }
  scope :only_children, -> { where('parent_id IS NOT NULL') }
  scope :with_users, -> { joins(:user).select('users.uid, users.name') }

  class << self

    def all_with_reply
      children = select_all_visible_children.group_by { |x| x.parent_id }
      select_all_visible_parents&.each { |x| x.children = children[x.id] || [] } || []
    end

    def find_by_id_with_children(id)
      parent = self.by_id(id).with_visible.with_users.select_posts
      return nil if parent.empty?

      children = self.by_parent_id(id).only_children.with_visible.with_users.select_posts
      # Relation で取得する様に変更したら仮想カラムが使えなくなってしまった
      # parent.children = children
      # parent

      # Relationは中身が1つの配列みたいな感じになっているので、map や each で回すと良い
      parent.map { |x| 
        x.children = children
        x
      }.first
    end

    def find_by_uid(uid)
      user_id = User.find_by_uid(uid)&.id
      user_id ? self.by_user_id(user_id).with_visible.with_users.select_posts : nil
    end

    def find_by_title(title)
      self.where('title LIKE ?', "%#{escape(title)}%").with_visible.with_users.select_posts
    end

    def find_by_text(text)
      self.where('text LIKE ?', "%#{escape(text)}%").with_visible.with_users.select_posts
    end

    def logical_delete_with_children(id)
      # find_by_id_with_children で検索すると削除済みの要素が検索出来ない為、敢えて親と子を別々に検索している
      post = self.find_by(id: id, is_deleted: false)
      return false if post.blank?

      post.update(is_deleted: true)
      self.by_parent_id(post.id).each { |child| child.update(is_deleted: true) }
      true
    end

    def to_secure
      { only: [:id, :parent_id, :user_id, :name, :title, :text, :is_deleted, :created_at, :updated_at, :children] }
    end

    private

      def escape(str)
        str.gsub(/([%_])/){ "\\#{$1}" }
      end

      def select_all_visible_parents
        self.with_visible.only_parents.with_users.select_posts
      end

      def select_all_visible_children
        self.with_visible.only_children.with_users.select_posts
      end

  end

end
