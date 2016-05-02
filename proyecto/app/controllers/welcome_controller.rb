class WelcomeController < ApplicationController
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
  
def test
  comprar(2,10)
end

#metodo que envia la orden de compra para comprar la materia prima cuando no se tiene
def comprar(_sku, cantidad)

  if _sku != nil
    
    grupoProveedor=(Proveedor.find_by skuProducto: _sku).grupoProveedor # Si no existe el proveedor se cae
    puts grupoProveedor
    #asumo que ya tengo plata
    #obtengo el ID del grupo
    #IDgrupo=(IdGrupo.find_by numeroGrupo: grupoProveedor).idGrupo

    #llamada a crear la orden de compra, retorna la orden de compra o error
    #@ordenCompra=RestClient.put 'http://mare.ing.puc.cl/oc/crear/', {:cliente => '571262b8a980ba030058ab4f', :proveedor => '571262b8a980ba030058ab4f', :sku => 47, :fechaEntrega => 1463797342000, :cantidad => 4, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'
    
    # Added stuff...

    # Get the group id from the number
    idgrupo=(IdGrupo.find_by numeroGrupo: grupoProveedor).idGrupo # Si no existe el idGrupo se cae, para prbar debes poblar la databse
    puts "idgrupo: " + idgrupo
    # Generate the OC
    @ordenCompra=RestClient.put 'http://mare.ing.puc.cl/oc/crear/', {:cliente => '571262b8a980ba030058ab4f', :proveedor => idgrupo, :sku => _sku, :fechaEntrega => 1463797342000, :cantidad => cantidad, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'
    # Get the other group link
    oc = ActiveSupport::JSON.decode(@ordenCompra) # http://stackoverflow.com/questions/5348449/get-a-particular-key-value-from-json-in-ruby
    url = 'http://integra'+grupoProveedor.to_s+'.ing.puc.cl/api/oc/recibir/' + oc['_id']
    puts "URL GRUPO: " + url

    # Send the OC to he other group
    #@anwer=RestClient.post url, @ordenCompra, :content_type => 'application/json'
    @answer = {aceptado: false, idoc: oc['_id']}.to_json # As long as othe groups don't implemen it, just to test. When implemented, use the code above this line.
    # answer to json
    ans = ActiveSupport::JSON.decode(@answer)
    # Check if positive answer
    if ans['aceptado']
      # They accepted it, YEI!
      # We are done here, they need to create the factura and send it back. We continue there.
      render :json => @answer
    else
      # They refused it :( Let's cancel the OC
      url = 'http://mare.ing.puc.cl/oc/anular/'+oc['_id']
      body = {id: oc['_id'], anulacion: 'OC rejected'}.to_json
      #Delete method doesn't accept body, so we need an advanced way of executing the code:
      @result = RestClient::Request.execute(method: :delete, url: url, payload: body, headers: {:content_type => 'application/json'})
      render :json => @result
    end
  end
end

  def index
    #OBTENER LOS ALMACENES

    comprar(40,10)

    key = 'W0B@c0w9.xqo1nQ'
    signature = 'GET'
    hmac = HMAC::SHA1.new(key)
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    almacenes = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/almacenes', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'}
    @almacenesJson = almacenes #Esta es solo para debug
    almacenesArreglo = almacenes.split("},")
    nAlmacenes = almacenesArreglo.length - 1
    #Creamos un arreglo 2d de los almacenes con sus atributos
    @almacenes = []
    i = 0
    until i > (nAlmacenes) do
      almacenAt = almacenesArreglo[i].split(',')
      almacenID = almacenAt[0].split(':')[1].tr('""', '')
      almacenGrupo = almacenAt[1].split(':')[1].tr('""', '')
      almacenPulmon = almacenAt[2].split(':')[1].tr('""', '')
      almacenDespacho = almacenAt[3].split(':')[1].tr('""', '')
      almacenRecepcion = almacenAt[4].split(':')[1].tr('""', '')
      almacenTotal = almacenAt[5].split(':')[1].tr('""', '')
      almacenUsado = almacenAt[6].split(':')[1].tr('""', '')
      almacenV = almacenAt[7].split(':')[1].tr('""', '')
      almacen = [almacenID, almacenGrupo, almacenPulmon, almacenDespacho, almacenRecepcion, almacenTotal, almacenUsado, almacenV]
      #new Almacen(almacenID, almacenUsado, almacenTotal, almacenRecepcion, almacenDespacho, almacenPulmon)
      @almacenes << almacen
      i += 1
    end
    #OBTENER EL CONTENIDO DE CADA ALMACEN
    i = 0
    signature = [1,2,3,4,5]
    clave = [1,2,3,4,5]
    productos = []
    until i > nAlmacenes do
      id = @almacenes[i][0]
      signature[i] = 'GET' + id
      hmac.update(signature[i])
      clave[i] = Base64.encode64("#{hmac.digest}")
      temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave[i], :content_type => 'application/json', :params => {:almacenId => id}}
      productos << temp
      i += 1
    end
    #Inicializamos nuestros productos en 0
    @semola = 0
    @levadura = 0
    @queso = 0
    @celulosa = 0
    @vino = 0
    #Contamos lo que hay en cada almacén
    i = 0
    until i > nAlmacenes do
      if productos[i].length != 2
        producto = productos[i].split(',')
        id = Integer(producto[0].split(':')[1].tr('""', ''))
        cantidad = Integer(producto[1].split(':')[1].tr('"}]"', ''))
        if id == 19
          @semola += cantidad
        elsif id == 27
          @levadura += cantidad
	elsif id == 40
          @queso += cantidad
	elsif id == 45
          @celulosa += cantidad
	elsif id == 47
          @vino += cantidad
	end
      end
      i += 1
    end
  end

end
