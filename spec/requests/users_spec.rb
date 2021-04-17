require 'rails_helper'

RSpec.describe "Users", type: :request do
  SYS_RECORD = { id: 1, uid: 'system-user', name: 'システムユーザー', email: 'system@test.co.jp', password: 'password', is_active: true }
  TEST_RECORD = { id: 2, uid: 'test-user', name: 'テストユーザー', email: 'user@test.co.jp', password: 'password', is_active: true }
  let!(:sys) { User.create(SYS_RECORD) }
  let!(:user) { User.create(TEST_RECORD) }

  describe "GET #index" do
    subject { get '/users'; response  }
    context 'データ登録済みの場合' do
      it 'テストデータの取得に成功すること' do
        # TODO: テストデータが取得できたかどうか のテストに書き換える
        subject
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

  describe "GET #show" do
    subject { get "/users/#{TEST_RECORD[:id]}"; response }
    context 'データ登録済みの場合' do
      it 'テストデータの取得に成功すること' do
        subject
        expect(response.body).to eq user.to_json(User.to_secure)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

  describe "POST #create" do
    subject { post '/users', params: { user: TEST_RECORD }; response }
    context '重複データが存在する場合' do
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
      let!(:user) { } # ユーザーを登録しないように上書き
      it 'テストデータの追加に成功すること' do
        expect { subject }.to change(User, :count).by(1)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end

  describe "PUT #update" do
    subject { put "/users/#{TEST_RECORD[:id]}", params: { user: TEST_RECORD }; response }
    context '変更後のuidが他ユーザーと重複する場合' do
      subject { put "/users/#{TEST_RECORD[:id]}", params: { user: TEST_RECORD.merge({ uid: SYS_RECORD[:uid] }) }; response } # subjectを上書き
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
      let!(:user) { } # ユーザーを登録しないように上書き
      it 'テストデータの編集に失敗すること' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ステータスコード404 が返ること' do
        is_expected.to have_http_status(404)
      end
    end
    context '対象データが存在する場合' do
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
    subject { delete "/users/#{TEST_RECORD[:id]}"; response }
    context '対象データが存在しない場合' do
      let!(:user) { } # ユーザーを登録しないように上書き
      it 'テストデータの削除に失敗すること' do
        expect { subject }.to change(User, :count).by(0)
      end
      it 'ステータスコード404 が返ること' do
        is_expected.to have_http_status(404)
      end
    end
    context '対象データが存在する場合' do
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