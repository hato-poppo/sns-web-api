class User < ApplicationRecord

  # Not null
  with_options presence: true do
    validates :uid
    validates :name
    validates :email
  end

  # Unique
  with_options uniqueness: true do
    validates :uid
    validates :email
  end

  # boolean
  validates :is_active, inclusion: { in: [ true, false ] }

  class << self

    def deactivate(uid)
      user = self.find_by_uid(uid)
      return nil if user.blank?

      user.update(is_active: false)
      user
    end

    def find_with_active_by_uid(uid)
      self.find_by(uid: uid, is_active: true)
    end

    def to_secure
      { only: [:id, :uid, :name, :email, :is_active, :created_at, :updated_at] }
    end

  end

end
