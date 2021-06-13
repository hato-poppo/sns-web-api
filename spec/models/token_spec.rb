require 'rails_helper'

RSpec.describe Token, type: :model do

  describe '#insert_hash' do
    subject { Token.insert_hash('admin', 'aaaa') }
    context '' do
      it 'trueが返ること' do
        is_expected.to eq true
      end
    end
  end

end
