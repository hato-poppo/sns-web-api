require 'rails_helper'

RSpec.describe "Roles", type: :request do

  describe "GET #index" do
    subject { get '/roles'; response  }
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

end
