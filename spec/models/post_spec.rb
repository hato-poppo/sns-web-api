require 'rails_helper'

RSpec.describe Post, type: :model do
  NON_EXISTS_POST = { id: 0 }
  TEST_POST = { id: 1, parent_id: 1, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  CHILD_POST = { id: 2, parent_id: 1, user_id: 1, title: 'テスト投稿（子）', text: 'これはテスト投稿の子投稿です。', is_deleted: false }
  CHILD_POST2 = { id: 3, parent_id: 1, user_id: 1, title: 'テスト投稿（子）', text: 'これはテスト投稿の子投稿2です。', is_deleted: false }
  ALONE_POST = { id: 4, parent_id: 4, user_id: 1, title: 'テスト投稿', text: 'これはテスト投稿です。', is_deleted: false }
  DELETED_POST = { id: 5, parent_id: 5, user_id: 1, title: 'テスト投稿（削除済み）', text: 'これは削除されたテスト投稿です。', is_deleted: true }
  DELETED_POST_CHILD = { id: 6, parent_id: 5, user_id: 1, title: 'テスト投稿（削除済み投稿の子）', text: 'これは削除されたテスト投稿の子投稿です。', is_deleted: false }
  HIVING_DELETED_CHILD_POST = { id: 7, parent_id: 7, user_id: 1, title: 'テスト投稿（削除済みの子投稿を持つ投稿）', text: 'これは削除された子投稿を持つテスト投稿です。', is_deleted: false }
  DELETED_CHILD_POST = { id: 8, parent_id: 7, user_id: 1, title: 'テスト投稿（削除済みの子投稿）', text: 'これは削除された子投稿です。', is_deleted: true }
  REGEXP_POST = { id: 9, parent_id: 9, user_id: 1, title: 'テスト投稿（正規表現）%_', text: '%()\||/_', is_deleted: false }
  let!(:posts) { Post.create([TEST_POST, CHILD_POST, CHILD_POST2, ALONE_POST, DELETED_POST, DELETED_POST_CHILD, HIVING_DELETED_CHILD_POST, DELETED_CHILD_POST, REGEXP_POST]) }
  let(:result_having_child_post) { 
    parent = Post.find_by_id(TEST_POST[:id])
    parent.update({ children: [Post.find_by_id(CHILD_POST[:id]), Post.find_by_id(CHILD_POST2[:id])] })
    parent
  }
  let(:result_alone_post) { Post.find_by_id(ALONE_POST[:id]) }
  let(:result_having_deleted_child_post) { Post.find_by_id(HIVING_DELETED_CHILD_POST[:id]) }
  let(:result_regexp_post) { Post.find_by_id(REGEXP_POST[:id]) } # wild card

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

  describe '#all_with_reply' do
    subject { Post.all_with_reply }
    context 'データが存在しない場合' do
      let!(:posts) {} # 投稿しないように上書き
      it '空の配列を取得できること' do
        is_expected.to eq []
      end
    end
    context 'データが存在する場合' do
      it '削除されていない投稿が全件取得できること' do
        is_expected.to eq [result_having_child_post, result_alone_post, result_having_deleted_child_post, result_regexp_post]
      end
    end
  end

  describe '#find_by_id_with_children' do
    subject { Post.find_by_id_with_children(id) }
    context '対象投稿が存在しない場合' do
      let(:id) { NON_EXISTS_POST[:id] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context '対象投稿が論理削除されている場合' do
      let(:id) { DELETED_POST[:id] }
      it 'nilが返ること' do
        is_expected.to eq nil
      end
    end
    context '対象投稿の子投稿が論理削除されている場合' do
      let(:id) { HIVING_DELETED_CHILD_POST[:id] }
      it '親投稿のみが返ること' do
        is_expected.to eq result_having_deleted_child_post
      end
    end
    context '対象投稿が存在している場合' do
      let(:id) { TEST_POST[:id] }
      it '子投稿を持った親投稿が返ること' do
        is_expected.to eq result_having_child_post
      end
    end
  end

  describe '#find_by_uid' do
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
      it '該当データを全件取得できること' do
        is_expected.to eq [Post.find_by_id(TEST_POST[:id]), Post.find_by_id(CHILD_POST[:id]), Post.find_by_id(CHILD_POST2[:id]), result_alone_post, result_having_deleted_child_post, result_regexp_post]
      end
    end
  end

  describe '#find_by_text' do
    subject { Post.find_by_text(text) }
    context '条件に一致するデータが存在しない場合' do
      let(:text) { '親投稿' }
      it '空の配列を取得できること' do
        is_expected.to eq []
      end
    end
    context '条件に一致するデータが存在する場合' do
      let(:text) { '子投稿' }
      it '該当データを全件取得できること' do
        is_expected.to eq [Post.find_by_id(CHILD_POST[:id]), Post.find_by_id(CHILD_POST2[:id]), result_having_deleted_child_post]
      end
    end
    context '_を条件にして一致するデータが存在する場合' do
      let(:text) { '_' }
      it '該当データを全件取得できること' do
        is_expected.to eq [result_regexp_post]
      end
    end
    context '%を条件にして一致するデータが存在する場合' do
      let(:text) { '%' }
      it '該当データを全件取得できること' do
        is_expected.to eq [result_regexp_post]
      end
    end
  end

  describe '#find_by_title' do
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
        is_expected.to eq [Post.find_by_id(CHILD_POST[:id]), Post.find_by_id(CHILD_POST2[:id])]
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

  describe '#logical_delete_with_children' do
    subject { Post.logical_delete_with_children(id) }
    context '対象投稿が存在しない場合' do
      let(:id) { NON_EXISTS_POST[:id] }
      it 'falseが返ること' do
        is_expected.to eq false
      end
    end
    context '対象投稿が存在 且つ 削除フラグがTRUE の場合' do
      let(:id) { DELETED_POST[:id] }
      it 'falseが返ること' do
        is_expected.to eq false
      end
    end
    context '対象投稿が存在 且つ 削除フラグがFALSE の場合' do
      let(:id) { TEST_POST[:id] }
      it 'trueが返ること' do
        is_expected.to eq true
      end
      it '子投稿も同時に削除されていること' do
        subject
        expect(Post.all_with_reply).to eq [result_alone_post, result_having_deleted_child_post, result_regexp_post]
      end
    end
  end

end
