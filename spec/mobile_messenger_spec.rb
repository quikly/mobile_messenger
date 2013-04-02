require 'spec_helper'

describe MobileMessenger do
  it 'should return correct version string' do
    MobileMessenger.version_string.should == "v#{MobileMessenger::VERSION}"
  end
end