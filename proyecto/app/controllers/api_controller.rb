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

      status = 200
    ## 
      begin
        orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' +idOrden 
        ordenParseada = JSON.parse orden
        @probando = ordenParseada.length
        sku = Integer(ordenParseada[0]["sku"])
        cantidad = Integer(ordenParseada[0]["cantidad"])
        inventario = Inventario.find_by sku: sku
         #Guardamos la OC en nuestra base de datos
        id = ordenParseada[0]["_id"]
        fechaCreacion = ordenParseada[0]["created_at"]
        canal = ordenParseada[0]["canal"]
        cliente = ordenParseada[0]["cliente"]
        despachada = 0
        precioUnitario = ordenParseada[0]["precioUnitario"]
        fechaEntrega = ordenParseada[0]["fechaEntrega"]
        rechazo =""
        anulacion = ""
        idFactura = ""
        if inventario == nil
        elsif cantidad > Integer(inventario.cantidadBodega) - Integer(inventario.cantidadVendida)
          estadoOC = false
          estado = "rechazada"
          rechazo = "falta de stock"
          Orden.create(idOrden:id, fechaCreacion:fechaCreacion, canal:canal, cliente:cliente, sku:sku, cantidad:cantidad, despachada:despachada, precioUnitario:precioUnitario, fechaEntrega:fechaEntrega, estado:estado, rechazo:rechazo, anulacion:anulacion, idFactura:idFactura)
          ## RECHAZAR ORDEN DE COMPRA
          RestClient.post  'http://moto.ing.puc.cl/oc/rechazar/'+idOrden.strip, {:id => idOrden, :rechazo => rechazo}.to_json, :content_type => 'application/json'
        else
          estadoOC = true
          ## RECEPCIONAR ORDEN DE COMPRA
          estado = "aceptada"
          Orden.create(idOrden:id, fechaCreacion:fechaCreacion, canal:canal, cliente:cliente, sku:sku, cantidad:cantidad, despachada:despachada, precioUnitario:precioUnitario, fechaEntrega:fechaEntrega, estado:estado, rechazo:rechazo, anulacion:anulacion, idFactura:idFactura)
          RestClient.post  'http://moto.ing.puc.cl/oc/recepcionar/'+idOrden.strip, {:id => idOrden}.to_json, :content_type => 'application/json'

          ### RESERVAR LA CANTIDAD!#####################
          cantidadVendida = (Inventario.find_by sku: sku).cantidadVendida.to_i
          cantidadVendida += cantidad.to_i
          (Inventario.find_by sku: sku).update(cantidadVendida: cantidadVendida)


        end
      rescue
        estadoOC = false
        status = 500
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
      Thread.new do
        ################ DEBERIA HACER SLEEP PARA QUE LA FACTURA NO LLEGUE ANTES DE QUE EL CLIENTE PROCESO LA ORDEN DE COMPRA ####################################
        #Makes the request pause 1.5 seconds
        #sleep 1.5

        if estadoOC
          #Creamos la factura
          begin
          factura = RestClient.put 'http://moto.ing.puc.cl/facturas/', {:oc => idOrden}.to_json, :content_type => 'application/json'
          facturaParseada = JSON.parse factura
          idFactura = facturaParseada["_id"]
          numeroGrupo = (IdGrupoProduccion.find_by idGrupo: cliente).numeroGrupo
          #respuesta = RestClient.get 'localhost:3000/api/facturas/recibir/' + idFactura
          puts "esta es la id de la factura"
          puts idFactura
          #puts respuesta
          puts "Se ha mandado la factura"
          respuesta = RestClient.get 'http://integra'+numeroGrupo.to_s+'.ing.puc.cl/api/facturas/recibir/' + idFactura, :content_type => 'application/json'
          respuestaParseada = JSON.parse respuesta
          puts respuestaParseada
          if respuestaParseada["validado"]
            puts "primera parte del if"
           (Orden.find_by idOrden: idOrden).update(idFactura:idFactura)
            puts "Se ha validado todo y este es el fin"
          else
            puts "no entro al if"
            ## HAY QUE ANULAR LA FACTURA
            RestClient.post  'http://moto.ing.puc.cl/facturas/cancel', {:id => idFactura, :motivo => "Rechazaron Factura"}.to_json, :content_type => 'application/json'

          end
          rescue
            puts "lo rescato"
          end
        
        end
      end


      ## falta aplicar el modelo de negocios

      render :status => status, json: {
      aceptado: estadoOC,
      idoc: idOrden, 
      }

  end





  def recibirFactura
    status = 200
    begin
      puts "Ha llegado factura!"
      estadoFactura = false
      idFactura = params[:idfactura]
      puts idFactura
        ## Obtenemos la factura
      factura = RestClient.get 'http://moto.ing.puc.cl/facturas/'+idFactura ##,{:Content_Type => 'application/json'}
      hashFactura = JSON.parse factura
      ##puts hashFactura
        ## Leemos la orden de compra correspondiente
      ordenCompra = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/'+ hashFactura[0]['oc'] ##,{:Content_Type => 'application/json'}
      hashOrdenCompra = JSON.parse ordenCompra
       ## Revisamos que los pagos calcen
       puts "Todo en orden hasta ahora"
       if  hashFactura[0]['total'] >= (hashOrdenCompra[0]['cantidad']*hashOrdenCompra[0]['precioUnitario'])
        estadoFactura = true
###################################LLAMAR AL METODO DE PAGO!!#################################################################################
      
        ## Crear thread que hace el pago de la factura que acabamos de aceptar
        Thread.new do
          ## realizar transferencia
          RestClient.put  'http://moto.ing.puc.cl/banco/trx', {:id => idFactura}.to_json, :content_type => 'application/json'

          ## enviar transferencia al grupo proveedor

          ## ver que acepten la transferencia


###################################LLAMAR AL METODO DE PAGAR FACTURA!!#################################################################################
          RestClient.post  'http://moto.ing.puc.cl/facturas/pay', {:id => idFactura}.to_json, :content_type => 'application/json'
          puts "Mandamos un True"

        end

      else
        RestClient.post  'http://moto.ing.puc.cl/facturas/reject', {:id => idFactura, :motivo => "No calzan valores"}.to_json, :content_type => 'application/json'

      end
    rescue
      status = 500
    end

      render :status => status, json: {
      validado: estadoFactura,
      factura: idFactura
    }
  end




  def recibirPago
    status = 200
    estadoPago = false
    puts params[:idtrx]
    puts params[:idfactura]
    begin
      ##montoCalza = false
      idPago = params[:idtrx]
      idFactura = params[:idfactura]
      #puts idPago
      #puts idFactura
      ## falta implementar la logica de negocios!

      transaccion = RestClient.get 'http://moto.ing.puc.cl/banco/trx/'+idPago
      hashTransaccion = JSON.parse transaccion
      puts hashTransaccion

      factura = RestClient.get 'http://moto.ing.puc.cl/facturas/'+idFactura ##,{:Content_Type => 'application/json'}
      hashFactura = JSON.parse factura
      puts hashFactura


      ## revisar si el monto es igual y si el pago se efectuo en nuestra cuenta

      if(hashFactura[0]['total'].to_i ==hashTransaccion[0]['monto'].to_i)
        estadoPago = true
        (Orden.find_by idFactura:idFactura).update(estado: "LPD")
      
      else
        puts 'monto no calza'       
      end
    rescue
      status = 500
    end

      ### REVISAR SI LA TRANSACCION NO SE REPITE
      ### REVISAR QUIEN LA MANDA A TRAVES DE LA CUENTA DEL BANCO

##################################### falta realizar el proceso con la bodega para programar el despacho  ##########################################################################

      render :status => status, json: {
      validado: estadoPago,
      trx: idPago
    }


      ## DESPACHAR INMEDIATAMENTE

      ## AVISAR A API DEL CLIENTE QUE LA CARGA FUE DESPACHADA, CUANDO TERMINE

  end



  def recibirDespacho
    status = 200
    begin
      despachoValido = true
      facturaDespacho = params[:idfactura]
      ## VER FACTURA Y LEER LOS PRODUCTOS
      puts facturaDespacho
      factura = RestClient.get 'http://moto.ing.puc.cl/facturas/'+facturaDespacho ,{:Content_Type => 'application/json'}
      hashFactura = JSON.parse factura
      puts "La orden de compra tiene id"
      puts hashFactura
      idOrdenDespacho = hashFactura[0]['oc']
      orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' +idOrdenDespacho
      hashOC = JSON.parse orden
      puts hashOC
      skuDespacho = hashOC[0]["sku"]
      cantidadDespacho = hashOC[0]["cantidad"]
      ## VER QUE HAYAMOS PROCESADO LA FACTURA
      puts "imprimimos lo que nos entrega ORDENS"
      puts idOrdenDespacho
      puts "Lo que es el parametro"
      puts ((Orden.find_by idOrden:idOrdenDespacho).idFactura).class

      if ((Orden.find_by idOrden:idOrdenDespacho).idFactura).empty? == false
        puts "existe la factura asociada"
      else
        puts "no existe la factura asociada"
      end
 

      ## VER QUE EN EL ALMACEN DE RECEPCION TENGA LOS PRODUCTOS QUE NECESITO
      ## RESPONDER A LA FACTURA
    rescue
      status = 500
    end

      render :status => status, json: {
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
