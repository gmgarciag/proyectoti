class ApiController < ApplicationController
require 'json'
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
  def consultarStock
    skuIngresado = params[:sku]
    cantidadRetorno = ((Inventario.find_by sku: skuIngresado).cantidadBodega).to_i - ((Inventario.find_by sku: skuIngresado).cantidadVendida).to_i
  
    # retorna un json con la informacion
    render json: {
      cantidad: cantidadRetorno,
      sku: skuIngresado
    }
  end

  def recibirOC
      estadoOC = false
      idOrden = params[:idoc]
############################# DEBE RESERVAR EL STOCK QUE SE ACEPTA #######################################################################################    

      ## falta aplicar el modelo de negocios
      ## leemos la orden de compra que esta en un arreglo con un json
      ##ordenDeCompra = (RestClient.get 'http://mare.ing.puc.cl/oc/obtener/'+idocIngresada)

      ##puts ordenDeCompra
      ##puts ordenDeCompra
      ## hay que ver que no sea invalido 
      #dOrden = params[:idOrden]
      orden = RestClient.get 'http://mare.ing.puc.cl/oc/obtener/' +idOrden 
      ordenParseada = JSON.parse orden
      @probando = ordenParseada.length
      sku = Integer(ordenParseada[0]["sku"])
      cantidad = Integer(ordenParseada[0]["cantidad"])
      inventario = Inventario.find_by sku: sku
      if inventario == nil
      elsif cantidad > Integer(inventario.cantidadBodega) - Integer(inventario.cantidadVendida)
        estadoOC = false
      else
        estadoOC = true
      end
        ##signature[i] = 'GET' + idBodega
        ##hmac.update(signature[i])
        ##clave[i] = Base64.encode64("#{hmac.digest}")
        ##temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave[i], :content_type => 'application/json', :params => {:almacenId => idBodega}}
        ##puts temp
      
      ## revisar que la orden este correcta
      ## que no falten campos y cantidades esten correctas

      ## revisar fecha y pedido

      ## revisar que tenga stock o mandar a fabricar
      ## comprometer ese stock

      ## si decido aceptarla, hacer todos los tramites! 
      ## generar la factura y mandarla
      ## ponerla como pendiente en alguna bd y revisar constantemente estado



      ## falta aplicar el modelo de negocios

      render json: {
      aceptado: estadoOC,
      idoc: idOrden
    }
  end


  def recibirFactura
      estadoFactura = false
      idFactura = params[:idfactura]
      puts idFactura
        ## Obtenemos la factura
      factura = RestClient.get 'http://mare.ing.puc.cl/facturas/'+idFactura ##,{:Content_Type => 'application/json'}
      hashFactura = JSON.parse factura
      ##puts hashFactura
        ## Leemos la orden de compra correspondiente
      ordenCompra = RestClient.get 'http://mare.ing.puc.cl/oc/obtener/'+ hashFactura[0]['oc'] ##,{:Content_Type => 'application/json'}
      hashOrdenCompra = JSON.parse ordenCompra
       ## Revisamos que los pagos calcen
       if  hashFactura[0]['total'] == (hashOrdenCompra[0]['cantidad']*hashOrdenCompra[0]['precioUnitario'])
        estadoFactura = true
       end

###################################LLAMAR AL METODO DE PAGO!!#################################################################################


          render json: {
      validado: estadoFactura,
      factura: idFactura
    }
  end

  def recibirPago
      estadoPago = false
      ##montoCalza = false
      idPago = params[:idtrx]
      idFactura = params[:idfactura]
      #puts idPago
      #puts idFactura
      ## falta implementar la logica de negocios!

      transaccion = RestClient.get 'http://mare.ing.puc.cl/banco/trx/'+idPago
      hashTransaccion = JSON.parse transaccion
      puts hashTransaccion

      factura = RestClient.get 'http://mare.ing.puc.cl/facturas/'+idFactura ##,{:Content_Type => 'application/json'}
      hashFactura = JSON.parse factura
      puts hashFactura

      ## revisar si el monto es igual y si el pago se efectuo en nuestra cuenta

      if(hashFactura[0]['total'].to_i ==hashTransaccion[0]['monto'].to_i)
        estadoPago = true
        ##if()
      
      else
        puts 'monto no calza'       
      end

##################################### falta realizar el proceso con la bodega para programar el despacho  ##########################################################################

        render json: {
      validado: estadoPago,
      trx: idPago
    }
  end

end