# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class SubscriptionsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/subscription"
  
  def activate
    Admin::BaseController.class_eval do
      before_filter :add_subscription_tab
    
      def add_subscription_tab
   		 @extension_tabs << [:subscriptions]
      end
    end

	  Payment.class_eval do
 			belongs_to :subscription

		  private
		  def check_payments                            
		    return unless subscription_id.nil? 
				return unless order.checkout_complete    
		    order.pay! if order.payment_total >= order.total
		  end
    end

    Admin::PaymentsController.class_eval do
      belongs_to :subscription
      before_filter :load_data
      
      private
      def load_data
        if params.key? "subscription_id"
          @subscription = Subscription.find(params[:subscription_id])
        end
      end
      
    end

		Variant.additional_fields += [ {:name => 'Subscribable', :only => [:variant], :use => 'select', :value => lambda { |controller, field| [["False", false], ["True", true]]  } } ]

		Variant.class_eval do
			has_many :subscriptions
		end
		
		User.class_eval do
			has_many :subscriptions
		end	
		
		Creditcard.class_eval	do
			has_many :subscriptions
		end
 
		Checkout.class_eval do
			before_save :subscriptions_check
			private 
			def subscriptions_check
				return unless process_creditcard?
				
				payment_profile_key = nil

				order.line_items.each do |line_item|
				  if (line_item.variant.is_master? && line_item.variant.product.subscribable?) || (!line_item.variant.is_master? && line_item.variant.subscribable?)

					if payment_profile_key.nil?
							#setup payment profile
							gateway = Gateway.find(:first, :conditions => {:active => true, :environment => ENV['RAILS_ENV']})
							cc = order.payments[0].creditcard
							cc.number = creditcard[:number]
							
							#TODO: figure out why email address is not present in gateway options.
							gate_opts = cc.gateway_options
							gate_opts[:email] = order.user.email
							gate_opts[:customer] = order.user.email
							
							response = gateway.provider.store(cc, gate_opts)
							cc.gateway_error(response) unless response.success?
						
							payment_profile_key = response.params['customerCode']	
						end
						
						#get subscription info
						interval = line_item.variant.option_values.detect { |ov| ov.option_type.name == "subscription-interval"}.name
						duration =  line_item.variant.option_values.detect { |ov| ov.option_type.name == "subscription-duration"}.name

						#create subscription
						subscription = Subscription.create(	:interval => interval, 
																								:duration => duration, 
																								:user => order.user, 
																								:variant => line_item.variant, 
																								:creditcard => order.payments[0].creditcard,
																								:payment_profile_key => payment_profile_key)
						
						#add dummy first payment (real payment was taken by normal checkout)
				 		payment = CreditcardPayment.create(:subscription => subscription, :amount => line_item.variant.price, :type => "CreditcardPayment", :creditcard => order.payments[0].creditcard)
						payment.creditcard_txns == order.payments[0].creditcard_txns
						subscription.payments << payment
						subscription.save
					end
				end
			end
		end
	
	  Gateway::Bogus.class_eval do
	    def store(creditcard, options = {})      
        if Gateway::Bogus::VALID_CCS.include? creditcard.number 
          ActiveMerchant::Billing::Response.new(true, "Bogus Gateway: Forced success", {}, :test => true, :customerCode => '12345')
        else
          ActiveMerchant::Billing::Response.new(false, "Bogus Gateway: Forced failure", {:message => 'Bogus Gateway: Forced failure'}, :test => true)
        end      
      end
    end
    
	 end

end

