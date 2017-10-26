require 'spec_helper'

describe MobileMessenger do
  it 'should return correct version string' do
    expect(MobileMessenger.version_string).to eq("v#{MobileMessenger::VERSION}")
  end
end