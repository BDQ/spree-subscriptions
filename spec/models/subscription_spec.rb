require File.dirname(__FILE__) + '/../spec_helper'

describe Subscription do
  before(:each) do
    @subscription = Subscription.new
  end

  it "should be valid" do
    @subscription.should be_valid
  end
end
