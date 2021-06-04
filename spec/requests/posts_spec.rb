require 'rails_helper'

RSpec.describe "Posts", type: :request do
  TEST_POST = { id: 1, parent_id: 1, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  CHILD_POST = { id: 2, parent_id: 1, user_id: 1, title: 'テスト投稿（子）', text: 'これはテスト投稿の子投稿です。', is_deleted: false }
  CHILD_POST2 = { id: 3, parent_id: 1, user_id: 1, title: 'テスト投稿（子）', text: 'これはテスト投稿の子投稿2です。', is_deleted: false }
  ALONE_POST = { id: 4, parent_id: 4, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  DELETED_POST = { id: 5, parent_id: 5, user_id: 1, title: 'テスト投稿（削除済み）', text: 'これは削除されたテスト投稿です。', is_deleted: true }
  DELETED_POST_CHILD = { id: 6, parent_id: 5, user_id: 1, title: 'テスト投稿（削除済み投稿の子）', text: 'これは削除されたテスト投稿の子投稿です。', is_deleted: false }
  HIVING_DELETED_CHILD_POST = { id: 7, parent_id: 7, user_id: 1, title: 'テスト投稿（削除済みの子投稿を持つ投稿）', text: 'これは削除された子投稿を持つテスト投稿です。', is_deleted: false }
  DELETED_CHILD_POST = { id: 8, parent_id: 7, user_id: 1, title: 'テスト投稿（削除済みの子投稿）', text: 'これは削除された子投稿です。', is_deleted: true }
  WILD_CARD_POST = { id: 9, parent_id: 9, user_id: 1, title: 'テスト投稿（ワイルドカード）%_', text: 'これはワイルドカードの%や_が含まれたテスト投稿です。', is_deleted: false }

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
end
