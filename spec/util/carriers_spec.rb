require 'spec_helper'

describe MobileMessenger::Util::Carriers do
  context "carriers" do
    it "returns Unknown Carrier for id 0" do
      expect(MobileMessenger::Util::Carriers.carrier_name(0)).to eq("Unknown Carrier")
    end
    
    it "returns Verizon Wireless for id 4" do
      expect(MobileMessenger::Util::Carriers.carrier_name(4)).to eq("Verizon Wireless")
    end
    
    it "returns an id from a known carrier name" do
      expect(MobileMessenger::Util::Carriers.carrier_id("Verizon Wireless")).to eq(4)
    end
    
    it "returns nil for an unknown carrier name" do
      expect(MobileMessenger::Util::Carriers.carrier_id("Does Not Exist")).to eq(nil)
    end
    
  end
  
end
