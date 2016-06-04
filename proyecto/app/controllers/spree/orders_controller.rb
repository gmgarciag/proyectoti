module Spree
  class OrdersController < Spree::StoreController
    require 'rest-client'
    require 'rubygems'
    require 'base64'
    require 'cgi'
    require 'hmac-sha1'
    before_action :check_authorization
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products', 'spree/orders'

    respond_to :html

    before_action :assign_order_with_lock, only: :update
    skip_before_action :verify_authenticity_token, only: [:populate]

    def moverA_Despacho idBoleta, direccion, cantidad, sku, precio
    idDespacho = (Almacen.find_by depacho:true).almacenId
    @id = idDespacho
    cliente = 'b2c'
    cantidad = cantidad.to_i
    precio = precio.to_i
    sku = sku.to_i
    cantidadBodega = ((Inventario.find_by sku: sku).cantidadBodega).to_i
    cantidadBodega = cantidadBodega - cantidad
    (Inventario.find_by sku: sku).update(cantidadBodega: cantidadBodega)
    cantidadVendida = ((Inventario.find_by sku: sku).cantidadVendida).to_i
    cantidadVendida = cantidadVendida - cantidad
    (Inventario.find_by sku: sku).update(cantidadVendida: cantidadVendida)
    key = 'W0B@c0w9.xqo1nQ'
    hmac = HMAC::SHA1.new(key)
    signature = 'GET' + idDespacho
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho}}
    contenido = JSON.parse temp
    i=0
    necesario = cantidad
    restante = cantidad
    while contenido[i].nil? == false do
      sku_ = Integer(contenido[i]["_id"])
      total = Integer(contenido[i]["total"])
      if sku_ == sku
        if total >= cantidad
          necesario = 0
          restante = 0
          while cantidad > 0
          key = 'W0B@c0w9.xqo1nQ'
          hmac = HMAC::SHA1.new(key)
          signature = 'GET' + idDespacho + sku.to_s
          hmac.update(signature)
          clave = Base64.encode64("#{hmac.digest}")
          stock = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => cantidad}}
          stockParseado = JSON.parse stock
          puts stockParseado.length
          k = 0
          puts cantidad
          while k < stockParseado.length
            idProducto = stockParseado[k]["_id"]
            key = 'W0B@c0w9.xqo1nQ'
            hmac = HMAC::SHA1.new(key)
            signature = 'DELETE' + idProducto + direccion + precio.to_s + idBoleta
            hmac.update(signature)
            clave = Base64.encode64("#{hmac.digest}")
            RestClient::Request.execute(method: :delete, url: 'http://integracion-2016-dev.herokuapp.com/bodega/stock', payload: {:productoId => idProducto, :direccion => direccion, :precio => precio, :oc => idBoleta}, headers: {Authorization: 'INTEGRACION grupo1:'+clave})
            k += 1
            end
          cantidad -= k
          end
            else
                necesario = cantidad - total
                restante = cantidad - total
                while total > 0
                #Despachamos lo que teniamos en despacho
                key = 'W0B@c0w9.xqo1nQ'
                hmac = HMAC::SHA1.new(key)
                signature = 'GET' + idDespacho + sku.to_s
                hmac.update(signature)
                clave = Base64.encode64("#{hmac.digest}")
                stock = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => total}}
                stockParseado = JSON.parse stock
                puts stockParseado.length
                k = 0
                while k < stockParseado.length
                  idProducto = stockParseado[k]["_id"]
                  key = 'W0B@c0w9.xqo1nQ'
                  hmac = HMAC::SHA1.new(key)
                  signature = 'DELETE' + idProducto + direccion + precio.to_s + idBoleta
                  hmac.update(signature)
                  clave = Base64.encode64("#{hmac.digest}")
                  RestClient::Request.execute(method: :delete, url: 'http://integracion-2016-dev.herokuapp.com/bodega/stock', payload: {:productoId => idProducto, :direccion => direccion, :precio => precio, :oc => idBoleta}, headers: {Authorization: 'INTEGRACION grupo1:'+clave})
                  k += 1
                  end
                total -= k
                end
                #@necesario = necesario
              end
            else
               #necesario = cantidad
               #restante = cantidad
            end
            i += 1
          end
          while necesario > 0 do
            i = Almacen.first.id
            #recorremos los almacenes buscando el producto
            nAlmacenes = Almacen.last.id
            while i <= nAlmacenes 
              id = Almacen.find(i).almacenId
              key = 'W0B@c0w9.xqo1nQ'
              hmac = HMAC::SHA1.new(key)
              signature = 'GET' + id
              hmac.update(signature)
              clave = Base64.encode64("#{hmac.digest}")
              temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id}}
              contenido = JSON.parse temp
              j=0
              while contenido[j].nil? == false do
                sku_ = Integer(contenido[j]["_id"])
                total = Integer(contenido[j]["total"])
                if sku_ == sku && id != idDespacho
                  #Encontramos el producto
                  signature = 'GET' + id.to_s + sku_.to_s
                  hmac.update(signature)
                  clave = Base64.encode64("#{hmac.digest}")
                  if necesario != 0
                  puts necesario
                  temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id, :sku => sku_, :limit => necesario}}
                  productos = JSON.parse temp
                  @productos = productos
                  puts productos
                  k = 0
                  while k < productos.length
                   idProducto = productos[k]["_id"]
                   key = 'W0B@c0w9.xqo1nQ'
                   hmac = HMAC::SHA1.new(key)
                   signature = 'POST' + idProducto + idDespacho
                   hmac.update(signature)
                   clave = Base64.encode64("#{hmac.digest}")
                   RestClient.post  'http://integracion-2016-dev.herokuapp.com/bodega/moveStock', {:productoId => idProducto, :almacenId => idDespacho}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
                  k += 1
                  end
                  necesario -= k
                  end 
                  end 
                j += 1
              end
              i += 1
            end
    end
    #Enviamos lo restante
   while restante > 0
   key = 'W0B@c0w9.xqo1nQ'
   hmac = HMAC::SHA1.new(key)
   signature = 'GET' + idDespacho + sku.to_s
   hmac.update(signature)
   clave = Base64.encode64("#{hmac.digest}")
   stock = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => restante}}
   stockParseado = JSON.parse stock
   puts stockParseado.length
   k = 0
   while k < stockParseado.length
   idProducto = stockParseado[k]["_id"]
   key = 'W0B@c0w9.xqo1nQ'
   hmac = HMAC::SHA1.new(key)
   signature = 'DELETE' + idProducto + direccion + precio.to_s + idBoleta
   hmac.update(signature)
   clave = Base64.encode64("#{hmac.digest}")
   RestClient::Request.execute(method: :delete, url: 'http://integracion-2016-dev.herokuapp.com/bodega/stock', payload: {:productoId => idProducto, :direccion => direccion, :precio => precio, :oc => idBoleta}, headers: {Authorization: 'INTEGRACION grupo1:'+clave})
   k += 1
   end
   restante -= k
   end
  end
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
      # 2,147,483,647 is crazy. See issue #2695.
      if quantity.between?(1, 2_147_483_647)
        if quantity <= (StockItem.find_by id: aux).count_on_hand
        begin
          order.contents.add(variant, quantity, options)
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
        else
        error = Spree.t(:please_enter_reasonable_quantity)
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
        iva = $iva
        $montoBruto = facturaParseada["bruto"]
        bruto = $montoBruto
        $total = facturaParseada["total"]
        total = $total
        urlOk = 'http%3A%2F%2Flocalhost:3000/spree/orders/confirmarCompra/' + boleta
        urlFail = 'http://www.uc.cl'
        url = 'http://integracion-2016-dev.herokuapp.com/web/pagoenlinea?callbackUrl='+urlOk+'&cancelUrl='+urlFail+'&boletaId=' + boleta
        redirect_to url
        #precio = NuestroProducto.find(aux).precio
        #moverA_Despacho boleta, direccion, quantity, sku, precio
        Ticket.create(idBoleta:boleta, direccion:direccion, sku:sku, cantidad:quantity, iva:iva, bruto:bruto, total:total)
      end
    end
    def despachar
        boleta = params[:boleta]
        sku = (Ticket.find_by idBoleta: boleta).sku
        cantidad = (Ticket.find_by idBoleta: boleta).cantidad
        iva = (Ticket.find_by idBoleta: boleta).iva
        bruto = (Ticket.find_by idBoleta: boleta).bruto
        total = (Ticket.find_by idBoleta: boleta).total
        precio = (NuestroProducto.find_by sku:sku).precio
        direccion = (Ticket.find_by idBoleta: boleta).direccion
        puts direccion
        moverA_Despacho boleta, direccion, cantidad, sku, precio
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
