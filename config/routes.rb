map.resources :subscriptions, :has_many => [:creditcards]

map.namespace :admin do |admin|
	admin.resources :subscriptions, :has_many => [:payments, :creditcards], :member => {:fire => :put}
  admin.resources :subscriptions do |subscriptions|
		subscriptions.resources :creditcard_payments
	end
end