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
    stock: cantidadRetorno,
    sku: skuIngresado
    }
    rescue
     render json: {
    stock: 0,
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
        puts 'esta es la orden parseada'
        puts ordenParseada
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
        puts 'entrando al if'
        if sku == 19 || sku == 27 || sku == 40 || sku == 45 || sku == 47
          if inventario == nil
            puts 'respuesta es nil'
          elsif cantidad > Integer(inventario.cantidadBodega) - Integer(inventario.cantidadVendida)
            estadoOC = false
            puts 'no hay inventario'
            estado = "rechazada"
            rechazo = "falta de stock"
            Orden.create(idOrden:id, fechaCreacion:fechaCreacion, canal:canal, cliente:cliente, sku:sku, cantidad:cantidad, despachada:despachada, precioUnitario:precioUnitario, fechaEntrega:fechaEntrega, estado:estado, rechazo:rechazo, anulacion:anulacion, idFactura:idFactura)
            ## RECHAZAR ORDEN DE COMPRA
            RestClient.post  'http://moto.ing.puc.cl/oc/rechazar/'+idOrden.strip, {:id => idOrden, :rechazo => rechazo}.to_json, :content_type => 'application/json'
          else
            estadoOC = true
            ## RECEPCIONAR ORDEN DE COMPRA
            puts 'hay inventario'
            estado = "aceptada"
            Orden.create(idOrden:id, fechaCreacion:fechaCreacion, canal:canal, cliente:cliente, sku:sku, cantidad:cantidad, despachada:despachada, precioUnitario:precioUnitario, fechaEntrega:fechaEntrega, estado:estado, rechazo:rechazo, anulacion:anulacion, idFactura:idFactura)
            RestClient.post  'http://moto.ing.puc.cl/oc/recepcionar/'+idOrden.strip, {:id => idOrden}.to_json, :content_type => 'application/json'

            ### RESERVAR LA CANTIDAD!#####################
            cantidadVendida = (Inventario.find_by sku: sku).cantidadVendida.to_i
            cantidadVendida += cantidad.to_i
            (Inventario.find_by sku: sku).update(cantidadVendida: cantidadVendida)
          end
        else
          estadoOC = false
          estado = "rechazada"
          rechazo = "no se vende"
          Orden.create(idOrden:id, fechaCreacion:fechaCreacion, canal:canal, cliente:cliente, sku:sku, cantidad:cantidad, despachada:despachada, precioUnitario:precioUnitario, fechaEntrega:fechaEntrega, estado:estado, rechazo:rechazo, anulacion:anulacion, idFactura:idFactura)

        end
      rescue
        estadoOC = false
        status = 500
      end

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
          #respuestaParseada = { 'validado' => 'true'}
          respuestaParseada = JSON.parse respuesta
          puts respuestaParseada
          if respuestaParseada["validado"] == 'true' || respuestaParseada["validado"] == true ## REVISAR ESTE IF, NO SE SI ENTRA SIEMPRE, alomejor lo entrega como string
            puts "primera parte del if"
           ## Cambiar a lista para despachar!
           (Orden.find_by idOrden: idOrden).update(idFactura:idFactura)
           (Orden.find_by idOrden: idOrden).update(estado: 'esperando pago')
            puts "Se ha validado todo y este es el fin"
          else
            puts "no entro al if"
            ## HAY QUE ANULAR LA FACTURA
            (Orden.find_by idOrden: idOrden).update(idFactura:idFactura)
            (Orden.find_by idOrden: idOrden).update(estado: 'factura Rechazada')
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
      puts hashFactura
        ## Leemos la orden de compra correspondiente
      ordenCompra = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/'+ hashFactura[0]['oc'] ##,{:Content_Type => 'application/json'}
      hashOrdenCompra = JSON.parse ordenCompra
      puts hashOrdenCompra
       ## Revisamos que los pagos calcen
       puts "Todo en orden hasta ahora"
       if  hashFactura[0]['total'] >= (hashOrdenCompra[0]['cantidad']*hashOrdenCompra[0]['precioUnitario'])
      ## Revisamos si existe nuestro pedido
         puts 'llego 189'
         puts hashFactura[0]['oc']
         ##puts (Pedido.where(:idPedido => hashFactura[0]['oc'])).idPedido
         ## En este IF falla
        if Pedido.where(:idPedido => hashFactura[0]['oc'].strip).blank?
          ## No existe
           puts 'llego 192'
          estadoFactura = false
        else
           puts 'llego 195'
          ## Esta OK todo
          estadoFactura = true
          ## Crear thread que hace el pago de la factura que acabamos de aceptar
          Thread.new do
            idProveedor = hashOrdenCompra[0]['proveedor']
            numeroProveedor = (IdGrupoProduccion.find_by idGrupo: idProveedor).numeroGrupo
            cuentaProveedor = (IdGrupoProduccion.find_by idGrupo: idProveedor).idBanco
            ##numeroProveedor = (IdGrupoProduccion.find_by idGrupo: idProveedor).numeroGrupo
            ##cuentaProveedor = (IdGrupoProduccion.find_by idGrupo: idProveedor).idBanco
            ## realizar transferencia
            transferencia = RestClient.put  'http://moto.ing.puc.cl/banco/trx', {:monto => hashFactura[0]['total'], :origen => '572aac69bdb6d403005fb04e', :destino => cuentaProveedor}.to_json, :content_type => 'application/json'
            ## Para desarrollo
            ##transferencia = RestClient.put  'http://moto.ing.puc.cl/banco/trx', {:monto => hashFactura[0]['total'], :origen => '572aac69bdb6d403005fb04e', :destino => cuntaProveedor}.to_json, :content_type => 'application/json'
            hashTransferencia = JSON.parse transferencia
            puts 'este es el hash de la transferencia'
            puts hashTransferencia
	          (Pedido.find_by idPedido: hashFactura[0]['oc']).update(estado: 'se cayo envio trx')
            ## enviar transferencia al grupo proveedor
            respuestaTransferencia = RestClient.get 'http://integra'+numeroProveedor.to_s+'.ing.puc.cl/api/pagos/recibir/'+hashTransferencia['_id']+'?idfactura='+hashFactura[0]['_id'] ,{:Content_Type => 'application/json'}
            ##respuestaTransferencia = RestClient.get 'http://prod.integra10.ing.puc.cl/api/pagos/recibir/'+hashTransferencia[0]['_id']+'?idfactura='+hashFactura[0]['_id'] ,{:Content_Type => 'application/json'}
            #hasRespuestaTrans = {'validado' => 'true'}
            #puts 'aca deberia ir la respeusta al atransferencia'
            ## ver que acepten la transferencia
            hasRespuestaTrans = JSON.parse respuestaTransferencia
            puts hasRespuestaTrans
            if hasRespuestaTrans['validado'] == 'true' || hasRespuestaTrans['validado'] == true
              puts 'entro1'
              ordenComra1 = hashFactura[0]['oc']
              puts ordenComra1
              (Pedido.find_by idPedido: hashFactura[0]['oc']).update(estado: 'pagada')
              #elPedido = Pedido.where(:idPedido => hashFactura[0]['oc'])
              #elPedido.update(estado: 'pagada')
              ## Marcamos la factura como pagada
              RestClient.post  'http://moto.ing.puc.cl/facturas/pay', {:id => idFactura}.to_json, :content_type => 'application/json'
              puts 'termino'
            else
              puts 'No validaron el pago'
	      (Pedido.find_by idPedido: hashFactura[0]['oc']).update(estado: 'rechazo pago')
              RestClient.post  'http://moto.ing.puc.cl/facturas/reject', {:id => idFactura, :motivo => "No fue validada"}.to_json, :content_type => 'application/json'
            end
          end
        end

      else
        RestClient.post  'http://moto.ing.puc.cl/facturas/reject', {:id => idFactura, :motivo => "No calzan valores"}.to_json, :content_type => 'application/json'

      end
    rescue
      status = 500
    end

      render :status => 200, json: {
      validado: estadoFactura,
      idfactura: idFactura
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
      puts 'esta es la transaccion'
      puts hashTransaccion

      factura = RestClient.get 'http://moto.ing.puc.cl/facturas/'+idFactura ##,{:Content_Type => 'application/json'}
      hashFactura = JSON.parse factura
      puts 'esta es la factura'
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
      idtrx: idPago
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
      #id: "571262b8a980ba030058ab4f"#desarrollo
      id: "572aac69bdb6d403005fb042"#produccion
    }
  end 

  def enviarBanco
        render json: {
      #id: "572aac69bdb6d403005fb04e"#desarrollo
      id: "572aac69bdb6d403005fb04e"#produccion
    }
  end

  def enviarAlmacen
        render json: {
      #id: "571262aaa980ba030058a147"#desarrollo
      id: "572aad41bdb6d403005fb066"#produccion
    }
  end



end

