# encoding: utf-8
module Spree
  class UnicreditPagonlineController < Spree::StoreController
    ssl_required
    helper 'spree/orders'

    skip_before_filter :verify_authenticity_token
    before_filter :set_payment_method


    def show
      if current_order.present?
        @order = current_order
      else
        flash[:error] = 'ERROR, order not present'
        redirect_to checkout_state_url(:payment)
      end

      @body_id = 'unicredit'

      payment = @order.payments.order(created_at: :desc).where(state: :checkout).first
      payment.update_attribute(:temp_total, @order.total)

      # Preferred data
      numeroCommerciante = @payment_method.preferred_numero_commerciante
      stabilimento = @payment_method.preferred_stabilimento
      userID = @payment_method.preferred_user_id
      password = @payment_method.preferred_password
      valuta = @payment_method.preferred_valuta
      flagRiciclaOrdine = @payment_method.preferred_flag_ricicla_ordine ? 'Y' : 'N'
      flagDeposito = @payment_method.preferred_flag_deposito ? 'Y' : 'N'
      tipoRispostaApv = @payment_method.preferred_tipo_risposta_apv
      urlOk = @payment_method.preferred_url_ok
      urlKo = @payment_method.preferred_url_ko
      stringaSegreta = @payment_method.preferred_stringa_segreta

      # Order data
      numeroOrdine = "#{@order.number}--#{@order.payment_sequence}--#{payment.id}"
      totaleOrdine = (@order.total*100).to_i.to_s

      # Compute input string
      inputMac  = "numeroCommerciante=#{numeroCommerciante.strip}"
      inputMac << "&userID=#{userID.strip}"
      inputMac << "&password=#{password.strip}"
      inputMac << "&numeroOrdine=#{numeroOrdine.strip}"
      inputMac << "&totaleOrdine=#{totaleOrdine.strip}"
      inputMac << "&valuta=#{valuta.strip}"
      inputMac << "&flagDeposito=#{flagDeposito}"
      inputMac << "&urlOk=#{urlOk.strip}"
      inputMac << "&urlKo=#{urlKo.strip}"
      inputMac << "&tipoRispostaApv=#{tipoRispostaApv.strip}"
      inputMac << "&flagRiciclaOrdine=#{flagRiciclaOrdine}"
      inputMac << "&stabilimento=#{stabilimento.strip}"
      inputMac << "&#{stringaSegreta.strip}"
      # qui potrei aggiungere gli eventuali parametri facoltativi :
      # 'tipoPagamento' e 'causalePagamento'

      # Compute MAC code
      mac = mac_code(inputMac)

      # Compute the url
      inputUrl = "https://pagamenti.unicredito.it/initInsert.do?numeroCommerciante=#{numeroCommerciante.strip}"
      inputUrl << "&userID=#{userID.strip}"
      inputUrl << "&password=Password"
      inputUrl << "&numeroOrdine=#{numeroOrdine.strip}"
      inputUrl << "&totaleOrdine=#{totaleOrdine.strip}"
      inputUrl << "&valuta=#{valuta.strip}"
      inputUrl << "&flagDeposito=#{flagDeposito.strip}"
      inputUrl << "&urlOk=#{CGI.escape urlOk.strip}"
      inputUrl << "&urlKo=#{CGI.escape urlKo.strip}"
      inputUrl << "&tipoRispostaApv=#{tipoRispostaApv.strip}"
      inputUrl << "&flagRiciclaOrdine=#{flagRiciclaOrdine.strip}"
      inputUrl << "&stabilimento=#{stabilimento.strip}"
      inputUrl << "&mac=#{CGI.escape mac}"

      @form_url = inputUrl
    end

    def result_ko
      begin
        @order = get_order_from_params(params)
        stringaSegreta = @payment_method.preferred_stringa_segreta
      rescue
        flash[:error] = "ERROR: missing order params from PagOnline"
        redirect_to checkout_state_url(:payment)
        return
      end

      # make string for MAC code
      inputMac  = "numeroOrdine=#{params[:numeroOrdine]}"
      inputMac << "&numeroCommerciante=#{params[:numeroCommerciante]}"
      inputMac << "&stabilimento=#{params[:stabilimento]}"
      inputMac << "&esito=#{params[:esito]}"
      inputMac << "&#{stringaSegreta.to_s.strip}"

    	# Compute MAC code
      mac = mac_code(inputMac)

    	# test the MAC param
    	if mac == params[:mac]
        flash[:error] = "Unicredito PagOnline: payment cancelled"
        @order.increment(:payment_sequence)
        @order.save
        redirect_to checkout_state_url(:payment)
        return
      else
        flash[:error] = "ERROR: wrong MAC code, payment cancelled"
        redirect_to checkout_state_url(:payment)
        return
      end
    end


    def result_ok
      begin
        @order = get_order_from_params(params)
        stringaSegreta = @payment_method.preferred_stringa_segreta
        payment = get_payment_from_order_number(params[:numeroOrdine])
      rescue
        flash[:error] = "ERROR: missing order params from PagOnline"
        redirect_to checkout_state_url(:payment)
      end

      # make string for MAC code
      inputMac  = "numeroOrdine=#{params[:numeroOrdine]}"
      inputMac << "&numeroCommerciante=#{params[:numeroCommerciante]}"
      inputMac << "&stabilimento=#{params[:stabilimento]}"
      inputMac << "&esito=#{params[:esito]}"
    	inputMac << "&dataApprovazione=#{params[:dataApprovazione]}"
      inputMac << "&#{stringaSegreta.to_s.strip}"

    	# Compute MAC code
      mac = mac_code(inputMac)

    	# test the MAC param
    	if mac == params[:mac]
        @order.next # now order is completed with payment_state: "pending"

        payment.amount = payment.temp_total
        payment.temp_total = 0
        payment.started_processing
        payment.complete

        session[:order_id] = nil
        redirect_to order_url(@order, {:checkout_complete => true, :token => @order.token})
      else
        @order.payment.fail
        flash[:error] = "ERROR: wrong MAC code, payment cancelled"
        redirect_to checkout_state_url(:payment)
      end
    end


    def listener
      begin
        order = get_order_from_params(params)
        stringaSegreta = @payment_method.preferred_stringa_segreta
        payment = get_payment_from_order_number(params[:numeroOrdine])
      rescue
        flash[:error] = "ERROR: missing order params from PagOnline"
        redirect_to checkout_state_url(:payment)
      end

      return unless order

      # make string for MAC code
      input_string = request.fullpath.gsub(/^.*listener\?/,'').gsub(/&mac=.*$/, '')
      inputMac = CGI::unescape(input_string)
      inputMac << "&#{stringaSegreta.to_s.strip}"

    	# Compute MAC code
      mac = mac_code(inputMac)

    	# test the MAC param
    	if true || mac == params[:mac]
        if params[:tipomessaggio] == "PAYMENT_STATE" and params[:statoattuale] && payment.present? && order.present?

          asd

          case params[:statoattuale]

          when 'OK'
            unless payment.completed?
              payment.amount = payment.temp_total
              payment.temp_total = 0
              payment.started_processing
            end
            unless order.completed?
              order.state = "complete"
              order.save
              order.finalize!
            end
            @msg = "UnicreditPagonline: order completed"

          when 'IC'
            unless payment.completed?
              payment.amount = payment.temp_total
              payment.temp_total = 0
              payment.started_processing
              payment.complete
            end
            unless order.completed?
              order.state = "complete"
              order.save
              order.finalize!
            end
            @msg = "UnicreditPagonline: order completed & paid"

          when 'KO'
            unless payment.failed?
              payment.started_processing
              payment.failure
            end
            if order.completed?
              order.state = "payment"
              order.increment(:payment_sequence)
              order.save
            end
            @msg = "Unicredit Pagonline: payment failed"

          else
            @msg = "Unicredit Pagonline: message unknown"
          end
        else
          @msg = "Unicredit Pagonline: message unknown"
        end
      else
        flash[:error] = "ERROR: wrong MAC code, payment cancelled"
      end
      render :text => @msg
    end


    private

    def mac_code(string)
      return  Digest::MD5.base64digest(string)
    end

    def set_payment_method
      @payment_method = Spree::PaymentMethod.find_by_type Spree::BillingIntegration::UnicreditPagonline

      if @payment_method.blank?
        flash[:error] = "ERROR, UnicreditPagonline not available"
        redirect_to checkout_state_url(:payment)
      end
    end

    def get_order_from_params(params)
      Spree::Order.find_by_number params[:numeroOrdine].split('--').first
    end

    def get_payment_from_order_number(order_number)
      Spree::Payment.find(order_number.split('--').last)
    end

  end
end
