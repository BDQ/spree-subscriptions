SUMMARY
=======

This extension allows you to make variants subscribable and uses it's own internal billing process to handle the recurring charges. It relies on your payment gateway provider's credit card storage API to save credit card details and then uses a cron job to handle payments (and credit card expiry notifications).

This extension does not use pre-canned recurring billing functionality from third-party gateways, as we feel our approach is more flexible while still remaining PCI compliant.
 
INSTALLATION
------------

1. Install this extension

      script/extension install git://github.com/BDQ/spree-subscriptions.git

2. Run pending migrations

      rake db:migrate

3. There's two option types that need to be created and they are included in the seed data for the extension.

			rake db:seed

4. The extension includes a whenever (gem) schedule to setup a cron job to process billing / notifications, to generate the cron job run the following:

			whenever --load-file -w vendor/extensions/subscriptions/config/schedule.rb 
			
5. Using the admin interface you should now have a "Subscribable" drop-down list when adding / editing variants. If you select True on this drop down and the then set the subscription option types which are:
	
	Duration: The number of intervals between subscription renewals (charges).
	
	Interval: This can be either "Month" or "Year", combined with the duration above to calculate how often a subscription is renewed (charged).
	
	
NOTES
-----

This extension has only been tested with the Beanstream Gateway. Your payment gateway will need support the following methods:

*	.store - For saving credit card details and returning a payment profile identifier
*	.purchase - The purchase method needs to accept the payment profile identifier as a parameter.

If the ActiveMerchant implementation for your chosen gateway doesn't support these methods you can include them in the Spree Gateway wrapper, take a look at the Beanstream gateway class in Spree core in (vendor/extensions/payment_gateway/app/models/gateway/beanstream.rb).


Subscriptions never expire provided a valid credit card is kept on file.


The cron job will notify users of expiring credit cards, and will "expire" subscriptions if no new card details are provided when a subscription renewal is due.