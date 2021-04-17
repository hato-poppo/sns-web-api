require 'rails_helper'

RSpec.describe User, type: :model do
  ACTIVE_USER = { uid: 'exists', name: '存在テストユーザー', email: 'exists@test.co.jp', password: 'password', is_active: true }
  NON_EXISTS_USER = { uid: 'non-exists', name: '不存在テストユーザー' }
  NON_ACTIVE_USER = { uid: 'non-active', name: '非活性テストユーザー', email: 'non-active@test.co.jp', password: 'password', is_active: false }

  describe '#validate' do
    subject { User.new(params) }
    context 'uidが空の場合' do
      let(:params) { ACTIVE_USER.merge({ uid: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors[:uid]).to eq ["can't be blank"]
      end
    end
    context 'nameが空の場合' do
      let(:params) { ACTIVE_USER.merge({ name: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors[:name]).to eq ["can't be blank"]
      end
    end
    context 'emailが空の場合' do
      let(:params) { ACTIVE_USER.merge({ email: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors[:email]).to eq ["can't be blank"]
      end
    end
    context 'uidが重複している場合' do
      let!(:dup) { User.create(ACTIVE_USER) }
      let(:params) { NON_ACTIVE_USER.merge({ uid: ACTIVE_USER[:uid] }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors[:uid]).to eq ["has already been taken"]
      end
    end
    context 'emailが重複している場合' do
      let!(:dup) { User.create(ACTIVE_USER) }
      let(:params) { NON_ACTIVE_USER.merge({ email: ACTIVE_USER[:email] }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors[:email]).to eq ["has already been taken"]
      end
    end
    context 'is_activeがboolean以外の場合' do
      let(:params) { ACTIVE_USER.merge({ is_active: nil }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors[:is_active]).to eq ["is not included in the list"]
      end
    end
    context '全てのデータが正しい場合' do
      let(:params) { ACTIVE_USER }
      it 'バリデーションエラーが発生しないこと' do
        is_expected.to be_valid
      end
    end
  end

  describe '#find_by_uid' do
    subject { User.find_by_uid(uid) }
    context 'uidが一致するユーザーが存在しない場合' do
      let(:uid) { NON_EXISTS_USER[:uid] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context 'uidが一致するユーザーが存在する場合' do
      let!(:active_user) { User.create(ACTIVE_USER) }
      let(:uid) { ACTIVE_USER[:uid] }
      it 'ユーザー情報を取得できること' do
        is_expected.to eq active_user
      end
    end
  end

  describe '#find_with_active_by_uid' do
    subject { User.find_with_active_by_uid(uid) }
    context 'uidが一致するユーザーがノンアクティブの場合' do
      let!(:non_active_user) { User.create(NON_ACTIVE_USER) }
      let(:uid) { NON_ACTIVE_USER[:uid] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context 'uidが一致するアクティブユーザーが存在しない場合' do
      let(:uid) { NON_EXISTS_USER[:uid] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context 'uidが一致するアクティブユーザーが存在する場合' do
      let!(:active_user) { User.create(ACTIVE_USER) }
      let(:uid) { ACTIVE_USER[:uid] }
      it 'ユーザー情報を取得できること' do
        is_expected.to eq active_user
      end
    end
  end

  describe '#deactivate' do
    subject { User.deactivate(uid) }
    context '対象ユーザーが存在しない場合' do
      let(:uid) { NON_EXISTS_USER[:uid] }
      it 'ユーザー情報が更新されないこと' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context '対象ユーザーが存在 且つ ノンアクティブユーザー の場合' do
      let!(:non_active_user) { User.create(NON_ACTIVE_USER) }
      let(:uid) { NON_ACTIVE_USER[:uid] }
      it 'ユーザー情報が更新されないこと' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ユーザー情報が返ること' do
        is_expected.to eq non_active_user
      end
    end
    context '対象ユーザーが存在 且つ アクティブユーザー の場合' do
      let!(:active_user) { User.create(ACTIVE_USER) }
      let(:uid) { ACTIVE_USER[:uid] }
      it 'ユーザー情報が更新されること' do
        # 良い方法を模索中
      end
      it 'ユーザー情報が返ること' do
        active_user[:is_active] = 0
        is_expected.to eq (active_user)
      end
    end
  end
  
end