require 'rails_helper'

RSpec.describe User, type: :model do
  ACTIVE_USER = { login_id: 'exists', name: '存在テストユーザー', email: 'exists@test.co.jp', password: 'password', is_active: true }
  NON_EXISTS_USER = { login_id: 'non-exists', name: '不存在テストユーザー' }
  NON_ACTIVE_USER = { login_id: 'non-active', name: '非活性テストユーザー', email: 'non-active@test.co.jp', password: 'password', is_active: false }

  # バリデーションについてのテストが必要
  describe '#validate' do
    subject { User.new(params) }
    context 'login_idが空の場合' do
      let(:params) { ACTIVE_USER.merge({ login_id: '' }) }
      it '' do
        is_expected.not_to be_valid
      end
    end
    context 'nameが空の場合' do
      let(:params) { ACTIVE_USER.merge({ name: '' }) }
      it '' do
        is_expected.not_to be_valid
      end
    end
    context 'emailが空の場合' do
      let(:params) { ACTIVE_USER.merge({ email: '' }) }
      it '' do
        is_expected.not_to be_valid
      end
    end
    context 'login_idが重複している場合' do
      let!(:dup) { User.create(ACTIVE_USER) }
      let(:params) { NON_ACTIVE_USER.merge({ login_id: ACTIVE_USER[:login_id] }) }
      it '' do
        is_expected.not_to be_valid
      end
    end
    context 'emailが重複している場合' do
      let!(:dup) { User.create(ACTIVE_USER) }
      let(:params) { NON_ACTIVE_USER.merge({ email: ACTIVE_USER[:email] }) }
      it '' do
        is_expected.not_to be_valid
      end
    end

    # 良い判定方法が見つからなかった為、一時的にコメントアウト
    # context 'is_activeがboolean以外の場合' do
    #   let(:params) { ACTIVE_USER.merge({ is_active: 'true2' }) }
    #   it '' do
    #     is_expected.not_to including(:is_active).in_array(%w[ true, false ])
    #   end
    # end
    
    context '全てのデータが正しい場合' do
      let(:params) { ACTIVE_USER }
      it '' do
        is_expected.to be_valid
      end
    end
  end

  describe '#find_by_login_id' do
    subject { User.find_by_login_id(login_id) }
    context 'login_idが一致するユーザーが存在しない場合' do
      let(:login_id) { NON_EXISTS_USER[:login_id] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context 'login_idが一致するユーザーが存在する場合' do
      let!(:active_user) { User.create(ACTIVE_USER) }
      let(:login_id) { ACTIVE_USER[:login_id] }
      it 'ユーザー情報を取得できること' do
        is_expected.to eq active_user
      end
    end
  end

  describe '#find_with_active_by_login_id' do
    subject { User.find_with_active_by_login_id(login_id) }
    context 'login_idが一致するユーザーがノンアクティブの場合' do
      let!(:non_active_user) { User.create(NON_ACTIVE_USER) }
      let(:login_id) { NON_ACTIVE_USER[:login_id] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context 'login_idが一致するアクティブユーザーが存在しない場合' do
      let(:login_id) { NON_EXISTS_USER[:login_id] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context 'login_idが一致するアクティブユーザーが存在する場合' do
      let!(:active_user) { User.create(ACTIVE_USER) }
      let(:login_id) { ACTIVE_USER[:login_id] }
      it 'ユーザー情報を取得できること' do
        is_expected.to eq active_user
      end
    end
  end

  describe '#deactivate' do
    subject { User.deactivate(login_id) }
    context '対象ユーザーが存在しない場合' do
      let(:login_id) { NON_EXISTS_USER[:login_id] }
      it 'ユーザー情報が更新されないこと' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context '対象ユーザーが存在 且つ ノンアクティブユーザー の場合' do
      let!(:non_active_user) { User.create(NON_ACTIVE_USER) }
      let(:login_id) { NON_ACTIVE_USER[:login_id] }
      it 'ユーザー情報が更新されないこと' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ユーザー情報が返ること' do
        is_expected.to eq non_active_user
      end
    end
    context '対象ユーザーが存在 且つ アクティブユーザー の場合' do
      let!(:active_user) { User.create(ACTIVE_USER) }
      let(:login_id) { ACTIVE_USER[:login_id] }
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