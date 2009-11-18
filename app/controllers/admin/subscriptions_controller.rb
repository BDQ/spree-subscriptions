class Admin::SubscriptionsController < Admin::BaseController
  resource_controller
  before_filter :load_object, :only => [:fire]

  def fire   
    event = params[:e]
    Subscription.transaction do 
      @subscription.send("#{event}!")
    end
    flash[:notice] = t('subscription_updated')
  rescue Spree::GatewayError => ge
    flash[:error] = "#{ge.message}"
  ensure
    redirect_to :back
  end

  private

  def collection
    @search = Subscription.search(params[:search])
    @search.order ||= "descend_by_created_at"

    # turn on show-complete filter by default
    #unless params[:search] && params[:search][:checkout_completed_at_not_null]
    #  @search.checkout_completed_at_not_null = true 
    #end
    
    @collection = @search.paginate(:include  => [:user, :variant],
                                   :per_page => Spree::Config[:orders_per_page], 
                                   :page     => params[:page])

  end

end
