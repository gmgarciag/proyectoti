class WelcomeController < ApplicationController
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require 'net/sftp'



 #metodo que envia la orden de compra para comprar la materia prima cuando no se tiene
  def comprar(_sku,cantidad)

    if _sku != nil
      
      grupoProveedor=(Proveedor.find_by skuProducto: _sku).grupoProveedor
      puts grupoProveedor
      #asumo que ya tengo plata
      #obtengo el ID del grupo
      #IDgrupo=(IdGrupoProduccion.find_by numeroGrupo: grupoProveedor).idGrupo

    #llamada a crear la orden de compra, retorna la orden de compra o error
    #@ordenCompra=RestClient.put 'http://moto.ing.puc.cl/oc/crear/', {:cliente => '572aac69bdb6d403005fb042', :proveedor => '572aac69bdb6d403005fb042', :sku => 47, :fechaEntrega => 1463797342000, :cantidad => 4, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'

      end

    end

  def index

    @semola = 34




  end

  def comprar

    sku = params[:sku]
    cantidad = params[:cantidad]
    fechaEntrega = (params[:fechaEntrega]).to_time
    if sku != nil
      ## Debemos preguntar si el grupo tiene la cantidad del producto que necesitamos
      grupoProveedor = (Proveedor.find_by skuProducto: sku).grupoProveedor
      ## Nos conectamos a la API para consultar el stock que tienen
      respuestaStock = RestClient.get 'http://integra'+grupoProveedor+'.ing.puc.cl/api/consultar/'+sku ,{:Content_Type => 'application/json'}
      hashRespuesStock = JSON.parse respuestaStock
      ## Si el stock que tienen es suficiente creamos la orden de compra
      if hashRespuesStock['cantidad'] >= cantidad
        ## Buscamos el id del grupo proveedor
        idGrupo = (IdGrupoProduccion.find_by numeroGrupo: grupoProveedor).idGrupo
        ## Creamos la orden de compra
        ordenCompra=RestClient.put 'http://moto.ing.puc.cl/oc/crear/', {:cliente => '572aac69bdb6d403005fb042', :proveedor => idGrupo, :sku => sku, :fechaEntrega => fechaEntrega, :cantidad => cantidad, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'
        ## Ya creada la orden de compra tenemos que ir a la aplicacion del grupo proveedor y exigir dicha cantidad
        hashOrdenCompra = JSON.parse ordenCompra
        ## Esperamos la respuesta y si es positiva tendriamos que guardarla en una base de datos y esperar que nos llegue la factura, que generara el pago automaticamente
        if hashOrdenCompra['aceptado']
          ## Deberiamos guardar en la base de datos que tenemos una orden aceptada
          Pedido.create(idPedido: ordenCompra['idoc'] , creacion: Time.now , proveedor: idGrupo , cantidad: cantidad.to_i , despachado: 0 , fechaEntrega: fechaEntrega.to_i , estado: 'Aceptada' , transaccion: false)
        else
          ## 
        end
        ## Luego hay que esperar que el cliente nos despache
      else

      end
    end
    

    if _sku != nil
 
      grupoProveedor=(Proveedor.find_by skuProducto: _sku).grupoProveedor
      puts grupoProveedor
      #asumo que ya tengo plata
      #obtengo el ID del grupo
      #idGrupo=(IdGrupoProduccion.find_by numeroGrupo: grupoProveedor).idGrupo

      #llamada a crear la orden de compra, retorna la orden de compra o error
      @ordenCompra=RestClient.put 'http://moto.ing.puc.cl/oc/crear/', {:cliente => '572aac69bdb6d403005fb042', :proveedor => idGrupo, :sku => 47, :fechaEntrega => 1463797342000, :cantidad => 4, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'

    end

 end


end
