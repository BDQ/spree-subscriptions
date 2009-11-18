class SubscriptionMailer < ActionMailer::QueueMailer
  helper "spree/base"
  
  def paymenet_receipt(subscription)
    @subject    = Spree::Config[:site_name] + ' ' + 'Subscription Renewal #' + subscription.id.to_s
    @body       = {"subscription" => subscription}
    @recipients = subscription.user.email
    @from       = Spree::Config[:order_from]
    @sent_on    = Time.now
  end

	def expiry_warning(subscription, within)
    @subject    = Spree::Config[:site_name] + ' ' + 'Creditcard for Subscription #' + subscription.id.to_s + ' is due to expire'
    @body       = {"subscription" => subscription, "within" => within}
    @recipients = subscription.user.email
    @from       = Spree::Config[:order_from]
    @sent_on    = Time.now
	end
	
	def creditcard_expired(subscription)
    @subject    = Spree::Config[:site_name] + ' ' + 'Creditcard for Subscription #' + subscription.id.to_s + ' has expired'
    @body       = {"subscription" => subscription}
    @recipients = subscription.user.email
    @from       = Spree::Config[:order_from]
    @sent_on    = Time.now
	end
	
	def subscription_reactivated(subscription)
    @subject    = Spree::Config[:site_name] + ' ' + 'Subscription #' + subscription.id.to_s + ' has been reactivated'
    @body       = {"subscription" => subscription}
    @recipients = subscription.user.email
    @from       = Spree::Config[:order_from]
    @sent_on    = Time.now
	end
end
