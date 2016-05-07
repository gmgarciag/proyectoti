class ApiController < ApplicationController
require 'json'
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'



  def consultarStock
    ## Recibe el parametro del sku a consultar
    skuIngresado = params[:sku]
    ## Consultamos nuestra base de datos y calculamos el stock disponible para compra
    begin
    cantidadRetorno = ((Inventario.find_by sku: skuIngresado).cantidadBodega).to_i - ((Inventario.find_by sku: skuIngresado).cantidadVendida).to_i
 ## Retornamos el JSON con el stock
      render json: {
    cantidad: cantidadRetorno,
    sku: skuIngresado
    }
    rescue
     render json: {
    cantidad: 0,
    sku: skuIngresado
    }
    end
  end

  def recibirOC
    ## seteamos la respuesta del estado como falsa
      estadoOC = false
    ## leemos el parametro que ingreso el cliente
      idOrden = params[:idoc]
    ## 
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
        #Guardamos la OC en nuestra base de datos
        id = ordenParseada[0]["_id"]
        fechaCreacion = ordenParseada[0]["created_at"]
        canal = ordenParseada[0]["canal"]
        cliente = ordenParseada[0]["cliente"]
        sku = ordenParseada[0]["sku"]
        cantidad = ordenParseada[0]["cantidad"]
        despachada = 0
        precioUnitario = ordenParseada[0]["precioUnitario"]
        fechaEntrega = ordenParseada[0]["fechaEntrega"]
        estado = "aceptada"
        rechazo =""
        anulacion = ""
        idFactura = ""
        Orden.create(idOrden:id, fechaCreacion:fechaCreacion, canal:canal, cliente:cliente, sku:sku, cantidad:cantidad, despachada:despachada, precioUnitario:precioUnitario, fechaEntrega:fechaEntrega, estado:estado, rechazo:rechazo, anulacion:anulacion, idFactura:idFactura)
      
      end


############################# DEBE RESERVAR EL STOCK QUE SE ACEPTA #######################################################################################    

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


    ################ DEBERIA HACER SLEEP PARA QUE LA FACTURA NO LLEGUE ANTES DE QUE EL CLIENTE PROCESO LA ORDEN DE COMPRA ####################################
    #Makes the request pause 1.5 seconds
    #sleep 1.5

    #if estadoOC
      #Creamos la factura
     # begin
     # factura = RestClient.put 'http://mare.ing.puc.cl/facturas/', {:oc => idOrden}.to_json, :content_type => 'application/json'
      #facturaParseada = JSON.parse factura
      #idFactura = facturaParseada["_id"]
      #numeroGrupo = (IdGrupo.find_by idGrupo: cliente).numeroGrupo
      #respuesta = RestClient.get 'http://integra'+numeroGrupo.to_s+'.ing.puc.cl/api/facturas/recibir/' + idFactura
      #respuestaParseada = JSON.parse respuesta
      #if respuestaParseada[0]["validado"]
       # (Orden.find_by idOrden: idOrden).update(idFactura:idFactura)
      #end
      #rescue
      #end
    
    #end

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
        (Orden.find_by idFactura:idFactura).update(estado: "LPD")
      
      else
        puts 'monto no calza'       
      end

      ### REVISAR SI LA TRANSACCION NO SE REPITE
      ### REVISAR QUIEN LA MANDA A TRAVES DE LA CUENTA DEL BANCO

##################################### falta realizar el proceso con la bodega para programar el despacho  ##########################################################################

        render json: {
      validado: estadoPago,
      trx: idPago
    }


      ## DESPACHAR INMEDIATAMENTE

      ## AVISAR A API DEL CLIENTE QUE LA CARGA FUE DESPACHADA, CUANDO TERMINE

  end



  def recibirDespacho
    despachoValido = false
    facturaDespacho = params[:idfactura]
    ## VER FACTURA Y LEER LOS PRODUCTOS
    ## VER QUE HAYAMOS PROCESADO LA FACTURA
    ## VER QUE EN EL ALMACEN DE RECEPCION TENGA LOS PRODUCTOS QUE NECESITO
    ## RESPONDER A LA FACTURA
        render json: {
      validado: despachoValido
    }
    ## MODIFICAR LA BASE DE DATOS
    ## MOVER LOS PRODUCTOS DE RECEPCION Y PULMON A DEMAS ALMACENES



  end

  def enviarGrupo
        render json: {
      id: "571262b8a980ba030058ab4f"
    }
  end 

  def enviarBanco
        render json: {
      id: "571262c3a980ba030058ab5b"
    }
  end

  def enviarAlmacen
        render json: {
      id: "571262aaa980ba030058a147"
    }
  end

end
