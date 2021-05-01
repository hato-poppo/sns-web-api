class Role < ApplicationRecord

  # Not null
  with_options presence: true do
    validates :name
  end

  # Unique
  with_options uniqueness: true do
    validates :name
  end

  class << self

    def to_secure
      { only: [:id, :name] }
    end

  end

end
