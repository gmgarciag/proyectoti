module Spree
  class OrdersController < Spree::StoreController
    before_action :check_authorization
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products', 'spree/orders'

    respond_to :html
    before_action :assign_order_with_lock, only: :update
    skip_before_action :verify_authenticity_token, only: [:populate]

    def show
      @order = Order.find_by_number!(params[:id])
    end

    def update
      if @order.contents.update_cart(order_params)
        respond_with(@order) do |format|
          format.html do
            if params.has_key?(:checkout)
              @order.next if @order.cart?
              redirect_to checkout_state_path(@order.checkout_steps.first)
            else
              redirect_to cart_path
            end
          end
        end
      else
        respond_with(@order)
      end
    end

    # Shows the current incomplete order from the session
    def edit
      @order = current_order || Order.incomplete.find_or_initialize_by(guest_token: cookies.signed[:guest_token])
      associate_user
    end
    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      order    = current_order(create_order_if_necessary: true)
      variant  = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].to_i
      options  = params[:options] || {}
      direccion = params[:direccion]
      aux = variant.product_id
      if aux == 1
        sku = 19
      elsif aux == 2
        sku = 27
      elsif aux == 3
        sku = 40
      elsif aux == 4
        sku = 45
      elsif aux == 5
        sku = 47
      end
      puts direccion
      # 2,147,483,647 is crazy. See issue #2695.
      if quantity.between?(1, 2_147_483_647)
        begin
          order.contents.add(variant, quantity, options)
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
      else
        error = Spree.t(:please_enter_reasonable_quantity)
      end
      if error
        flash[:error] = error
        redirect_back_or_default(spree.root_path)
      else
        total = NuestroProducto.find(aux).precio * quantity
        factura = RestClient.put 'http://mare.ing.puc.cl/facturas/boleta', {:proveedor => '571262b8a980ba030058ab4f', :cliente => 'b2c', :total => total}
        facturaParseada = JSON.parse factura
        boleta = facturaParseada["_id"]
        $idBoleta = boleta
        $iva = facturaParseada["iva"]
        $montoBruto = facturaParseada["bruto"]
        $total = facturaParseada["total"]
        urlOk = 'http%3A%2F%2Flocalhost:3000/spree/orders/confirmarCompra'
        urlFail = 'http://www.uc.cl'
        boletaId = 111
        url = 'http://integracion-2016-dev.herokuapp.com/web/pagoenlinea?callbackUrl='+urlOk+'&cancelUrl='+urlFail+'&boletaId=' + boleta
        redirect_to url
      end
    end

    def mostrarBoleta
    
    end

    def empty
      if @order = current_order
        @order.empty!
      end

      redirect_to 'http://integracion-2016-dev.herokuapp.com/web/pagoenlinea'
    end

    def accurate_title
      if @order && @order.completed?
        Spree.t(:order_number, :number => @order.number)
      else
        Spree.t(:shopping_cart)
      end
    end

    def check_authorization
      order = Spree::Order.find_by_number(params[:id]) || current_order

      if order
        authorize! :edit, order, cookies.signed[:guest_token]
      else
        authorize! :create, Spree::Order
      end
    end

    private

      def order_params
        if params[:order]
          params[:order].permit(*permitted_order_attributes)
        else
          {}
        end
      end

      def assign_order_with_lock
        @order = current_order(lock: true)
        unless @order
          flash[:error] = Spree.t(:order_not_found)
          redirect_to root_path and return
        end
      end
  end
end
