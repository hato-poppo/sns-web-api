class Token < ApplicationRecord

  class << self

    def insert_hash(uid, payload)      
      # payload = { data: 'test' }
      user_id = User.find_by_uid(uid)&.id
      raise '指定のユーザーが見つかりません。' if user_id.nil?

      # まずは期限切れトークンがないかを確認し、あるなら削除しておく
      delete_dead_token(user_id)

      payload = { uid: uid, date: Time.zone.now, num: rand(0..9999) }
      hash = jwt_encode(payload)

      self.create({ user_id: user_id, hash: hash, limit: Time.zone.now + 14.days })
      true
    rescue => e
      #　なぜかこのモデルだけレコード登録時に必ずエラーが返る為、原因調査
      p e
      false
    end

    def authenticate?(hash)
      self.find_by_hash(hash).present?
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
        p dead_token
        dead_token.destroy if dead_token.present?
      end

  end
end
