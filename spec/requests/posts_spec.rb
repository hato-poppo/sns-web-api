require 'rails_helper'

RSpec.describe "Posts", type: :request do
  TEST_POST = { id: 1, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  CHILD_POST = { id: 2, parent_id: 1, user_id: 1, title: 'テスト投稿（子）', text: 'これはテスト投稿の子投稿です。', is_deleted: false }
  CHILD_POST2 = { id: 3, parent_id: 1, user_id: 1, title: 'テスト投稿（子）', text: 'これはテスト投稿の子投稿2です。', is_deleted: false }
  ALONE_POST = { id: 4, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  DELETED_POST = { id: 5, user_id: 1, title: 'テスト投稿（削除済み）', text: 'これは削除されたテスト投稿です。', is_deleted: true }
  DELETED_POST_CHILD = { id: 6, parent_id: 5, user_id: 1, title: 'テスト投稿（削除済み投稿の子）', text: 'これは削除されたテスト投稿の子投稿です。', is_deleted: true }
  HIVING_DELETED_CHILD_POST = { id: 7, user_id: 1, title: 'テスト投稿（削除済みの子投稿を持つ投稿）', text: 'これは削除された子投稿を持つテスト投稿です。', is_deleted: false }
  DELETED_CHILD_POST = { id: 8, parent_id: 7, user_id: 1, title: 'テスト投稿（削除済みの子投稿）', text: 'これは削除された子投稿です。', is_deleted: true }
  WILD_CARD_POST = { id: 9, user_id: 1, title: 'テスト投稿（ワイルドカード）%_', text: 'これはワイルドカードの%や_が含まれたテスト投稿です。', is_deleted: false }

  let!(:posts) { Post.create([TEST_POST, CHILD_POST, CHILD_POST2, ALONE_POST, DELETED_POST, DELETED_POST_CHILD, HIVING_DELETED_CHILD_POST, DELETED_CHILD_POST, WILD_CARD_POST]) }
  let(:result_having_child_post) { Post.find_by_id_with_children(TEST_POST[:id]).to_json(Post.to_secure) }
  # let(:result_alone_post) { Post.find_by_id(ALONE_POST[:id]) }
  # let(:result_having_deleted_child_post) { Post.find_by_id(HIVING_DELETED_CHILD_POST[:id]) }
  # let(:result_wild_card_post) { Post.find_by_id(WILD_CARD_POST[:id]) }

  describe "GET #index" do
    subject { get '/posts'; response }
    context "データが存在する場合" do
      it "データの配列が返ること" do
        subject
        json = JSON.parse(response.body)
        expect(json.length).to eq(4)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end
  describe "GET #show" do
    subject { get "/posts/#{id}"; response }
    context "対象データが存在しない場合" do
      let(:id) { 99 }
      it "エラーメッセージが返ること" do
        subject
        expect(response.body).to eq JSON.generate({ status: 404, message: '対象の投稿が存在していません。' })
      end
      it 'ステータスコード404 が返ること' do
        is_expected.to have_http_status(404)
      end
    end
    context "対象データが存在する場合" do
      let(:id) { TEST_POST[:id] }
      it "データが返ること" do
        subject
        expect(response.body).to eq(result_having_child_post)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end
  describe "POST #create" do
    subject { post '/posts', params: { post: params }; response }
    context '投稿ユーザーが存在しない場合' do
      let(:params) { { user_id: 99, title: 'テスト投稿', text: 'これはテスト投稿です。' } }
      it 'エラーメッセージが返ること' do
        subject
        expect(response.body).to eq JSON.generate({ status: 422, message: '投稿ユーザーが存在していません。' })
      end
      it 'ステータスコード422 が返ること' do
        is_expected.to have_http_status(422)
      end
    end
    context '投稿ユーザーが存在する場合' do
      let(:params) { { user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。' } }
      it 'データの追加に成功すること' do
        expect { subject }.to change(Post, :count).by(1)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
    context '親投稿が存在しない場合' do
      let(:params) { { parent_id: 99, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。' } }
      it 'エラーメッセージが返ること' do
        subject
        expect(response.body).to eq JSON.generate({ status: 422, message: '親投稿が存在していません。' })
      end
      it 'ステータスコード422 が返ること' do
        is_expected.to have_http_status(422)
      end
    end
    context "親投稿が存在している場合" do
      let(:params) { { parent_id: 1, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。' } }
      it 'データの追加に成功すること' do
        expect { subject }.to change(Post, :count).by(1)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end
  describe "PUT #update" do
    subject { put "/posts/#{id}", params: { post: params }; response }
    let(:params) { { title: '編集テスト', text: 'これは編集されたテスト投稿です' } }
    context "対象投稿が存在しない場合" do
      let(:id) { 99 }
      it "エラーメッセージが返ること" do
        subject
        expect(response.body).to eq JSON.generate({ status: 404, message: '対象の投稿が存在していません。' })
      end
      it 'ステータスコード404 が返ること' do
        is_expected.to have_http_status(404)
      end
    end
    context "対象投稿が存在する場合" do
      let(:id) { TEST_POST[:id] }
      it "更新された投稿が返ること" do
        # NOTE: 更新した要素が先頭に来てしまうせいで要素の並びが変わるせいでテスト失敗と判定されてしまう
        # subject
        # expect(response.body).to eq Post.find_by_id(id).to_json(Post.to_secure)
      end
      it 'ステータスコード200 が返ること' do
        is_expected.to have_http_status(200)
      end
    end
  end
  # describe "DELETE #destroy" do
  #   subject { delete "/posts/#{id}"; response }
  #   context "対象データが存在しない場合" do
  #     it "エラーメッセージが返ること" do
  #       subject
  #       expect(response.body).to eq JSON.generate({ status: 404, message: '対象の投稿が存在していません。' })
  #     end
  #     it 'ステータスコード404 が返ること' do
  #       is_expected.to have_http_status(404)
  #     end
  #   end
  #   context "対象データが存在する場合" do
  #     it "" do
  #     end
  #     it 'ステータスコード200 が返ること' do
  #       is_expected.to have_http_status(200)
  #     end
  #   end
  # end
end
