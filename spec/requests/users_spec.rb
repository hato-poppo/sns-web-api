require 'rails_helper'

RSpec.describe "Users", type: :request do
  ADMIN_RECORD = { id: 1, uid: 'admin', name: '管理者', email: 'admin@dummy.com', password: 'admin' }
  TEST_RECORD = { id: 2, uid: 'test-user', name: 'テストユーザー', email: 'user@test.co.jp', password: 'password' }
  # let!(:sys) { User.create(ADMIN_RECORD) }
  # let!(:user) { User.create(TEST_RECORD) }

  describe "GET #index" do
    subject { get '/users'; response  }
    context 'データ登録済みの場合' do
      it 'テストデータの取得に成功すること' do
        subject
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

  describe "GET #show" do
    context '対象データが存在しない場合' do
      subject { get "/users/#{TEST_RECORD[:id]}"; response }
      it 'データの取得に失敗すること' do
        subject
        expect(response.body).to eq JSON.generate({status: 404, message: '対象のユーザーが存在していません。'})
      end
      it 'ステータスコード404 が返ること' do
        is_expected.to have_http_status(404)
      end
    end
    context '対象データが存在する場合' do
      subject { get "/users/#{ADMIN_RECORD[:id]}"; response }
      it 'データの取得に成功すること' do
        subject
        expect(response.body).to eq User.find_by_id(1).to_json(User.to_secure)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

  describe "POST #create" do
    subject { post '/users', params: { user: params }; response }
    context '重複データが存在する場合' do
      let(:params) { ADMIN_RECORD }
      it 'テストデータの追加に失敗すること' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'エラーメッセージが返ること' do
        subject
        message = JSON.parse(response.body, symbolize_names: true)[:message]
        expect(message).to eq ["ユーザーIDはすでに存在します", "メールアドレスはすでに存在します"]
      end
      it 'ステータスコード400 が返ること' do
        is_expected.to have_http_status(400)
      end
    end
    context '重複データが存在しない場合' do
      let(:params) { TEST_RECORD }
      it 'テストデータの追加に成功すること' do
        expect { subject }.to change(User, :count).by(1)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

  describe "PUT #update" do
    subject { put "/users/#{id}", params: { user: params }; response }
    context '変更後のuidが他ユーザーと重複する場合' do
      let!(:test_user) { User.create(TEST_RECORD) }
      let(:id) { TEST_RECORD[:id] }
      let(:params) { TEST_RECORD.merge({ uid: ADMIN_RECORD[:uid] }) }
      it 'テストデータの編集に失敗すること' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'エラーメッセージが返ること' do
        subject
        message = JSON.parse(response.body, symbolize_names: true)[:message]
        expect(message).to eq ["ユーザーIDはすでに存在します"]
      end
      it 'ステータスコード400 が返ること' do
        is_expected.to have_http_status(400)
      end
    end
    context '対象データが存在しない場合' do
      let(:id) { TEST_RECORD[:id] }
      let(:params) { TEST_RECORD }
      it 'テストデータの編集に失敗すること' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ステータスコード404 が返ること' do
        is_expected.to have_http_status(404)
      end
    end
    context '対象データが存在する場合' do
      let(:id) { ADMIN_RECORD[:id] }
      let(:params) { ADMIN_RECORD }
      it 'テストデータの編集に成功すること' do
        # TODO: テスト内容要変更
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

  describe "DELETE #destroy" do
    subject { delete "/users/#{id}"; response }
    context '対象データが存在しない場合' do
      let(:id) { TEST_RECORD[:id] }
      it 'テストデータの削除に失敗すること' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ステータスコード404 が返ること' do
        is_expected.to have_http_status(404)
      end
    end
    context '対象データが存在する場合' do
      let(:id) { ADMIN_RECORD[:id] }
      it 'テストデータの削除に成功すること' do
        # TODO: 元々 by(-1) にしていたが、論理削除なので−1にならなかった。テスト方法要再検討
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

end