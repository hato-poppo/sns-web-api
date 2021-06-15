class Token < ApplicationRecord
  belongs_to :user

  scope :by_user_id, -> (user_id) { where(user_id: user_id) }
  scope :by_digest_hash, -> (hash) { where(digest_hash: hash) }
  scope :with_dead, -> { where("tokens.limit < '#{Time.zone.now}'") }
  scope :with_alive, -> { where("tokens.limit >= '#{Time.zone.now}'") }
  scope :with_user, -> { joins(:user).select('users.uid, users.name') }

  class << self

    def insert_hash(uid)
      user_id = User.find_by_uid(uid)&.id
      raise '指定のユーザーが見つかりません。' if user_id.nil?

      delete_dead_token(user_id)

      payload = { uid: uid, date: Time.zone.now, num: rand(0..9999) }
      hash = jwt_encode(payload)

      self.create({ user_id: user_id, digest_hash: hash, limit: token_limit })
    end

    def authenticate?(hash)
      self.by_digest_hash(hash).with_alive.first.present?
    end

    def loggedin_user(hash)
      self.by_digest_hash(hash).with_alive.first
    end

    private

      def jwt_encode(payload)
        require 'jwt'
        # IMPORTANT: set nil as password parameter
        JWT.encode(payload, nil, 'none')
      end

      def jwt_decode(hash)
        require 'jwt'
        # Set password to nil and validation to false otherwise this won't work
        JWT.decode hash, nil, false
      end

      def delete_dead_token(user_id)
        self.by_user_id(user_id).with_dead.first&.destroy
      end

      def token_limit
        Time.zone.now + 14.days
      end

  end
end
