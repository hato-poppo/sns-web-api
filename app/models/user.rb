class User < ApplicationRecord

  # Not null
  with_options presence: true do
    validates :login_id
    validates :name
    validates :email
  end

  # Unique
  with_options uniqueness: true do
    validates :login_id
    validates :email
  end

  # boolean
  validates :is_active, inclusion: { in: [ true, false ] }

  class << self

    def deactivate(login_id)
      user = self.find_by_login_id(login_id)
      return nil if user.blank?

      user.update(is_active: 0)
      self.find_by_login_id(login_id)
    end

    def find_with_active_by_login_id(login_id)
      self.find_by(login_id: login_id, is_active: 1)
    end

  end

end
