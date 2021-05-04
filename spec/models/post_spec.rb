require 'rails_helper'

RSpec.describe Post, type: :model do
  TEST_POST = { id: 1, parent_id: 1, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  ALONE_POST = { id: 2, parent_id: 2, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  CHILD_POST = { id: 3, parent_id: 1, user_id: 1, title: 'テスト投稿（子）', text: 'これはテスト投稿の子投稿です。', is_deleted: false }
  GRANDCHILD_POST = { id: 4, parent_id: 1, user_id: 1, title: 'テスト投稿（孫）', text: 'これはテスト投稿の孫投稿です。', is_deleted: false }
  DELETED_POST = { id: 5, parent_id: 5, user_id: 1, title: 'テスト投稿', text: 'これは削除されたテスト投稿です。', is_deleted: true }
  REGEXP_POST = { id: 6, parent_id: 6, user_id: 1, title: 'テスト投稿（正規表現）%()\||/_', text: '%()\||/_', is_deleted: false }

  describe '#validate' do
    subject { Post.new(params) }
    context 'parent_idが空の場合' do
      let(:params) { TEST_POST.merge({ parent_id: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors.full_messages).to eq ['親投稿IDを入力してください']
      end
    end
    context 'user_idが空の場合' do
      let(:params) { TEST_POST.merge({ user_id: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors.full_messages).to eq ['投稿者を入力してください']
      end
    end
    context 'titleが空の場合' do
      let(:params) { TEST_POST.merge({ title: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors.full_messages).to eq ['投稿タイトルを入力してください']
      end
    end
    context 'textが空の場合' do
      let(:params) { TEST_POST.merge({ text: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors.full_messages).to eq ['投稿内容を入力してください']
      end
    end
    context 'is_deletedがboolean以外の場合' do
      let(:params) { TEST_POST.merge({ is_deleted: nil }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors.full_messages).to eq ['削除フラグは一覧にありません']
      end
    end
    context '全てのデータが正しい場合' do
      let(:params) { TEST_POST }
      it 'バリデーションエラーが発生しないこと' do
        is_expected.to be_valid
      end
    end
  end

  describe '#find_parents' do
    subject { Post.find_parents }
    context 'データが存在しない場合' do
      it '空の配列を取得できること' do
        is_expected.to eq []
      end
    end
    context 'データが存在する場合' do
      let!(:posts) { Post.create([TEST_POST, ALONE_POST, CHILD_POST, GRANDCHILD_POST, DELETED_POST]) }
      it '未削除の親投稿が全て取得できること' do
        is_expected.to eq [Post.find_by_id(1), Post.find_by_id(2)]
      end
    end
  end

  describe '#find_children' do
    subject { Post.find_children }
    context 'データが存在しない場合' do
      it '空のhashを取得できること' do
        is_expected.to eq Hash.new([])
      end
    end
    context 'データが存在する場合' do
      let!(:posts) { Post.create([TEST_POST, ALONE_POST, CHILD_POST, GRANDCHILD_POST, DELETED_POST]) }
      let(:result) { { 1 => [Post.find_by_id(3), Post.find_by_id(4)] } }
      it '未削除の親投稿が全て取得できること' do
        is_expected.to eq result
      end
    end
  end

  describe '#all_with_reply' do
    subject { Post.all_with_reply }
    context 'データが存在しない場合' do
      it '空の配列を取得できること' do
        is_expected.to eq []
      end
    end
    context 'データが存在する場合' do
      let!(:posts) { Post.create([TEST_POST, ALONE_POST, CHILD_POST, GRANDCHILD_POST, DELETED_POST]) }
      let!(:result) { 
        parent = Post.find_by_id(1)
        parent.update!({ children: [Post.find_by_id(3), Post.find_by_id(4)] })
        [parent, Post.find_by_id(2)]
      }
      it '全件取得できること' do
        is_expected.to eq result
      end
    end
  end

  describe '#find_by_uid' do
    let!(:posts) { Post.create([TEST_POST, ALONE_POST, CHILD_POST, GRANDCHILD_POST, DELETED_POST]) }
    subject { Post.find_by_uid(uid) }
    context '条件に一致するユーザーが存在しない場合' do
      let(:uid) { 'non-exists' }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context '条件に一致するデータが存在しない場合' do
      TEST_RECORD = { id: 2, uid: 'test-user', name: 'テストユーザー', email: 'user@test.co.jp', password: 'password', role_id: 2 }
      let!(:user) { User.create(TEST_RECORD) }
      let(:uid) { TEST_RECORD[:uid] }
      it '空の配列を取得できること' do
        is_expected.to eq []
      end
    end
    context '条件に一致するデータが存在する場合' do
      let(:uid) { 'admin' }
      let(:result) { [Post.find_by_id(1), Post.find_by_id(2), Post.find_by_id(3), Post.find_by_id(4)] }
      it '該当データを全件取得できること' do
        is_expected.to eq result
      end
    end
  end

  describe '#find_by_text' do
    let!(:posts) { Post.create([TEST_POST, ALONE_POST, CHILD_POST, GRANDCHILD_POST, DELETED_POST, REGEXP_POST]) }
    subject { Post.find_by_text(text) }
    # 条件にエスケープ必須の文字も追加すること
    context '条件に一致するデータが存在しない場合' do
      let(:text) { '親投稿' }
      it '空の配列を取得できること' do
        is_expected.to eq []
      end
    end
    context '条件に一致するデータが存在する場合' do
      let(:text) { '子投稿' }
      it '該当データを全件取得できること' do
        is_expected.to eq [Post.find_by_id(3)]
      end
    end
  end

  describe '#find_by_title' do
    let!(:posts) { Post.create([TEST_POST, ALONE_POST, CHILD_POST, GRANDCHILD_POST, DELETED_POST, REGEXP_POST]) }
    subject { Post.find_by_title(title) }
    context '条件に一致するデータが存在しない場合' do
      let(:title) { '（親）' }
      it '空の配列を取得できること' do
        is_expected.to eq []
      end
    end
    context '条件に一致するデータが存在する場合' do
      let(:title) { '（子）' }
      it '該当データを全件取得できること' do
        is_expected.to eq [Post.find_by_id(3)]
      end
    end
    context '_を条件にして一致するデータが存在する場合' do
      let(:title) { '_' }
      it '該当データを全件取得できること' do
        is_expected.to eq [Post.find_by_id(REGEXP_POST[:id])]
      end
    end
    context '%を条件にして一致するデータが存在する場合' do
      let(:title) { '%' }
      it '該当データを全件取得できること' do
        is_expected.to eq [Post.find_by_id(REGEXP_POST[:id])]
      end
    end
  end

  describe '#logical_delete' do
    let!(:default_post) { Post.create(TEST_POST) }
    subject { Post.logical_delete(id) }
    context '対象投稿が存在しない場合' do
      let(:id) { 0 } #NON_EXISTS_USER[:id]
      it '投稿情報が更新されないこと' do
        expect { subject }.to change(Post, :count).by(0)
      end
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context '対象投稿が存在 且つ 削除フラグがTRUE の場合' do
      let!(:deleted_post) { Post.create(DELETED_POST) }
      let(:id) { 5 }
      it '投稿レコードが更新されないこと' do
        expect { subject }.to change(User, :count).by(0)
      end
      it '投稿レコードが返ること' do
        is_expected.to eq deleted_post
      end
    end
    context '対象投稿が存在 且つ 削除フラグがFALSE の場合' do
      let(:id) { 1 }
      it '投稿情報が更新されること' do
        # 良い方法を模索中
      end
      it '更新後の投稿情報が返ること' do
        default_post[:is_deleted] = true
        is_expected.to eq (default_post)
      end
    end
  end

end
