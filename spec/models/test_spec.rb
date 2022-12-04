require 'rails_helper'

#Rspecのテストの練習をする。

RSpec.describe '四則演算' do
  it '1 + 1 は 2 になること' do
    expect(1 + 1).to eq 2
  end
end

RSpec.describe User do
  describe '#greet' do
    let(:user) { User.new(name: 'Alice', age: age) }
    subject { user.show }
    context '年齢が20歳の場合' do
      let(:age) { 20 }
      it { is_expected.to eq 'Aliceは成人です' }
    end
    context '年齢が10歳の場合' do
      let(:age) { 10 }
      it { is_expected.to eq 'Aliceは未成年です' }
    end
  end
end
