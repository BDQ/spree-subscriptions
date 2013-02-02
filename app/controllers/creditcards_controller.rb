class CreditcardsController < ApplicationController
  before_filter :load_data, :only => :update
  resource_controller

  update.success.wants.html { redirect_to subscription_url(@subscription) }

  update.after do
    if @subscription.state == "expired"
      @subscription.reactive
      
      SubscriptionMailer.deliver_subscription_reactivated(@subscription)
    end
  end

  private
  def load_data
    @subscription = Subscription.find(params[:subscription_id])
  end

end
