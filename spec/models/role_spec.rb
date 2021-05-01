require 'rails_helper'

RSpec.describe Role, type: :model do
  TEST_ROLE = { name: 'テストユーザー' }

  describe '#validate' do
    subject { Role.new(params) }
    context 'nameが空の場合' do
      let(:params) { TEST_ROLE.merge({ name: '' }) }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors.full_messages).to eq ["名称を入力してください"]
      end
    end
    context 'nameが重複している場合' do
      let!(:dup) { Role.create(TEST_ROLE) }
      let(:params) { TEST_ROLE }
      it 'バリデーションエラーが発生すること' do
        is_expected.not_to be_valid
        expect(subject.errors.full_messages).to eq ["名称はすでに存在します"]
      end
    end
  end

end
