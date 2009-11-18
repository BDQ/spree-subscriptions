require File.dirname(__FILE__) + '/../spec_helper'

describe ExpiryNotification do
  before(:each) do
    @expiry_notification = ExpiryNotification.new
  end

  it "should be valid" do
    @expiry_notification.should be_valid
  end
end
