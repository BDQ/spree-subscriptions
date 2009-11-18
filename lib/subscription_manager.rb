include ActionView::Helpers::DateHelper
	
class SubscriptionManager
	
	def SubscriptionManager.process
		subscriptions = Subscription.find(:all, :conditions => {:state => 'active'})
		check_for_renewals(subscriptions)
		check_for_creditcard_expiry(subscriptions)
	end
	
	def SubscriptionManager.check_for_renewals(subscriptions)

		subscriptions.each do |sub|
			next unless sub.due_on.to_time <= Time.now()
			#subscription due for renewal
			
			#re-curring payment
			amount = sub.variant.price * 100
			gateway = Gateway.find(:first, :conditions => {:active => true, :environment => ENV['RAILS_ENV']})
			response = gateway.purchase(amount, sub.payment_profile_key)
			puts response.to_yaml	
			if response.success?
				payment = CreditcardPayment.create(:subscription => sub, :amount => sub.variant.price, :type => "CreditcardPayment", :creditcard => sub.creditcard)
			  payment.creditcard_txns << CreditcardTxn.new(
	        :amount => amount,
	        :response_code => response.authorization,
	        :txn_type => CreditcardTxn::TxnType::PURCHASE
	      )
				subscription.payments << payment
				SubscriptionMailer.deliver_paymenet_receipt(sub)
			end
		end
	end
	
	def SubscriptionManager.check_for_creditcard_expiry(subscriptions)

		subscriptions.each do |sub|
			next unless sub.creditcard.expiry_date.expiration < (Time.now + 3.months)
			
			#checks for credit cards due to expiry with all the following ranges
			[1.day, 3.days, 1.week, 2.weeks, 3.weeks, 1.month, 2.months, 3.months].each do |interval|
				within =  distance_of_time_in_words(Time.now, Time.now + interval)
							 
				if sub.creditcard.expiry_date.expiration.to_time < (Time.now + interval) && sub.end_date.to_time > (Time.now + interval) 
					
					unless ExpiryNotification.exists?(:subscription_id => sub.id, :interval => interval.seconds.to_i)
						notification = ExpiryNotification.create(:subscription_id => sub.id, :interval => interval.seconds)
						SubscriptionMailer.deliver_expiry_warning(sub, within)
					end

					break
				end
			end
			
			#final check if credit card has actually expired
			if sub.creditcard.expiry_date.expiration < Time.now 
				sub.expire
				SubscriptionMailer.deliver_creditcard_expired(sub)
			end
			
		end		
	end
end