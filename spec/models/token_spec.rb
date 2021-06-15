require 'rails_helper'

RSpec.describe Token, type: :model do

  describe '#insert_hash' do
    subject { Token.insert_hash(uid) }
    context '指定ユーザーが存在しない場合' do
      let(:uid) { 'test' }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context '指定ユーザーが存在する場合' do
      let(:uid) { 'admin' }
      it 'トークンハッシュが返ること' do
        is_expected.to eq Token.find_by_user_id(1).digest_hash
      end
    end
  end

end
