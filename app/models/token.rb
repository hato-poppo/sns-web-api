class Token < ApplicationRecord

  class << self

    def insert_hash(uid, payload)
      user_id = User.find_by_uid(uid)&.id
      raise '指定のユーザーが見つかりません。' if user_id.nil?

      delete_dead_token(user_id)

      payload = { uid: uid, date: Time.zone.now, num: rand(0..9999) }
      hash = jwt_encode(payload)

      self.create({ user_id: user_id, digest_hash: hash, limit: token_limit })
    end

    def authenticate?(hash)
      self.find_by(digest_hash: hash).where("limit <= #{Time.zone.now}").present?
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
        # self.find_by_user_id(user_id)&.destroy で良いと思う
        dead_token = self.find_by_user_id(user_id)
        dead_token.destroy if dead_token.present?
      end

      def token_limit
        Time.zone.now + 14.days
      end

  end
end
