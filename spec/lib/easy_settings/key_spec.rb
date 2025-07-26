require 'rails_helper'

RSpec.describe EasySettings::IntegerKey, type: :model do
  let(:key) { described_class.new('int') }
  let(:setting) { EasySetting.new(name: 'int') }

  it 'rejects non numeric input' do
    expect(key.from_params(setting, 'abc')).to be_nil
  end

  it 'converts numeric string' do
    expect(key.from_params(setting, '123')).to eq 123
  end
end
