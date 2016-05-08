class WelcomeController < ApplicationController
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require 'net/sftp'



 #metodo que envia la orden de compra para comprar la materia prima cuando no se tiene
  def index

  end

  def comprar

    sku = (params[:sku]).to_i
    cantidad = (params[:cantidad]).to_i
    fechaEntrega = (params[:fechaEntrega]).to_time
    puts 'el SKU es '
    puts sku
    puts 'la cantidad es '
    puts cantidad
    puts 'la fecha es '
    puts fechaEntrega
    if sku != nil
      ## Debemos preguntar si el grupo tiene la cantidad del producto que necesitamos
      grupoProveedor = ((Proveedor.find_by skuMateriaPrima: sku)).grupoProveedor
      puts 'El grupo provedor es'
      puts grupoProveedor
      ## Nos conectamos a la API para consultar el stock que tienen
      respuestaStock = RestClient.get 'http://integra'+grupoProveedor.to_s+'.ing.puc.cl/api/consultar/'+sku.to_s ,{:Content_Type => 'application/json'}
      hashRespuesStock = JSON.parse respuestaStock
      puts hashRespuesStock
      puts "tienen de stock" 
      puts hashRespuesStock['cantidad']
      ## Si el stock que tienen es suficiente creamos la orden de compra
      if hashRespuesStock['cantidad'] >= cantidad
        ## Buscamos el id del grupo proveedor
        idGrupo = (IdGrupo.find_by numeroGrupo: grupoProveedor).idGrupo
        puts 'el id del grupo es'
        puts idGrupo
        ## Creamos la orden de compra
        fechaEnFormato = (fechaEntrega.to_i) * 1000
        ordenCompra=RestClient.put 'http://mare.ing.puc.cl/oc/crear/', {:cliente => '571262b8a980ba030058ab4f', :proveedor => idGrupo, :sku => sku, :fechaEntrega => fechaEnFormato, :cantidad => cantidad, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'
        ## Ya creada la orden de compra tenemos que ir a la aplicacion del grupo proveedor y exigir dicha cantidad
        hashOrdenCompra = JSON.parse ordenCompra
        puts "la orden de compra se creo con"
        puts hashOrdenCompra
        ## Enviamos al grupo proveedor la orden de compra
        respuestaEnvioOC = RestClient.get 'http://integra'+grupoProveedor.to_s+'.ing.puc.cl/api/oc/recibir/'+hashOrdenCompra['_id'] ,{:Content_Type => 'application/json'}
        hashEnvioOC = JSON.parse respuestaEnvioOC
        puts "la respuesta es"
        puts hashEnvioOC
        ## Esperamos la respuesta y si es positiva tendriamos que guardarla en una base de datos y esperar que nos llegue la factura, que generara el pago automaticamente
        if hashOrdenCompra['aceptado'] == true
          ## Deberiamos guardar en la base de datos que tenemos una orden aceptada
          puts 'se acepto la orden'
          Pedido.create(idPedido: ordenCompra['idoc'] , creacion: Time.now , proveedor: idGrupo , cantidad: cantidad.to_i , despachado: 0 , fechaEntrega: fechaEntrega.to_i , estado: 'Aceptada' , transaccion: false)
        else
          ## 
          puts 'no me lee que la acepto'
        end
        ## Luego hay que esperar que el cliente nos despache
      else

      end
    end

 end


end
