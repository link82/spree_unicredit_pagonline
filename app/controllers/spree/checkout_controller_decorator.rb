module Spree
  CheckoutController.class_eval do
    before_filter :redirect_for_unicredit_pagonline, :only => [:update]

    private

    def redirect_for_unicredit_pagonline
      return unless (params[:state] == "payment")
      return unless params[:order][:payments_attributes]
      @payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])

      if @payment_method && @payment_method.kind_of?(Spree::BillingIntegration::UnicreditPagonline)
        payment_method_hash = { "payments_attributes" => [ {"payment_method_id" => @payment_method.id} ] }
        @order.update_attributes payment_method_hash

        redirect_to main_app.unicredit_pagonline_show_path
      end
    end
  end
end
