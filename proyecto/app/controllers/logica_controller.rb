class LogicaController < ApplicationController
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
require "resolv-replace.rb"


def contestar
  idOrden = params[:idOrden]
  orden = RestClient.get 'http://mare.ing.puc.cl/oc/obtener/' +idOrden 
  ordenParseada = JSON.parse orden
  @probando = ordenParseada.length
  sku = Integer(ordenParseada[0]["sku"])
  cantidad = Integer(ordenParseada[0]["cantidad"])
  inventario = Inventario.find_by sku: sku
  if inventario == nil
  elsif cantidad >= Integer(inventario.cantidadBodega) - Integer(inventario.cantidadVendida)
    return false
  else
    return true
  end
end


=begin
def actualizarInventario
  #OBTENER LOS ALMACENES
    key = 'W0B@c0w9.xqo1nQ'
    signature = 'GET'
    hmac = HMAC::SHA1.new(key)
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    almacenes = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/almacenes', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'}
    @almacenesJson = almacenes #Esta es solo para debug
    almacenesParseado = JSON.parse almacenes
    almacenesArreglo = almacenes.split("},")
    nAlmacenes = almacenesArreglo.length - 1
    #Creamos un arreglo 2d de los almacenes con sus atributos
    @almacenes = []
    i = 0
    until i > (nAlmacenes) do
      almacenID = almacenesParseado[i]["_id"]
      almacenPulmon = almacenesParseado[i]["pulmon"]
      almacenDespacho = almacenesParseado[i]["despacho"]
      almacenRecepcion = almacenesParseado[i]["recepcion"]
      almacenTotal = almacenesParseado[i]["totalSpace"]
      almacenUsado = almacenesParseado[i]["usedSpace"]
      begin
        Almacen.find(i).update(id: i, almacenId:almacenID, espacioUtilizado:almacenUsado, espacioTotal:almacenTotal, recepcion:almacenRecepcion, depacho:almacenDespacho, pulmon:almacenPulmon)
        rescue
      Almacen.create(id: i, almacenId:almacenID, espacioUtilizado:almacenUsado, espacioTotal:almacenTotal, recepcion:almacenRecepcion, depacho:almacenDespacho, pulmon:almacenPulmon)
      end
      i += 1
    end
    #OBTENER EL CONTENIDO DE CADA ALMACEN
    i = 0
    signature = []
    clave = []
    productos = []
    until i > nAlmacenes do
      id = Almacen.find(i).almacenId
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
    #las materias primas que necesitamos para producir
    @leche = 0
    @sueroDeLeche = 0
    @azucar = 0
    @uva = 0
    Inventario.create(sku:7, cantidadBodega:0, cantidadVendida:0)    
    Inventario.create(sku:19, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:25, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:27, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:39, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:40, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:41, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:45, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:47, cantidadBodega:0, cantidadVendida:0)
    #Contamos lo que hay en cada almacén
    i = 0
    until i > nAlmacenes do
      productosParseado = JSON.parse productos[i]
      j = 0
      while productosParseado[j].nil? == false do
      id = Integer(productosParseado[j]["_id"])
      cantidad = Integer(productosParseado[j]["total"])
      if id == 7
        @leche += cantidad
      elsif id == 19
        @semola += cantidad
      elsif id == 25
        @azucar += cantidad
      elsif id == 27
        @levadura += cantidad
      elsif id == 39
        @uva += cantidad
      elsif id == 40
        @queso += cantidad
      elsif id == 41
        @sueroDeLeche += cantidad
      elsif id == 45
        @celulosa += cantidad
      elsif id == 47
        @vino += cantidad
      end
      j += 1
      end
      i += 1
    end
    (Inventario.find_by sku:7).update(cantidadBodega:@leche)
    (Inventario.find_by sku:19).update(cantidadBodega:@semola)
    (Inventario.find_by sku:25).update(cantidadBodega:@azucar)
    (Inventario.find_by sku:27).update(cantidadBodega:@levadura)
    (Inventario.find_by sku:39).update(cantidadBodega:@uva)
    (Inventario.find_by sku:40).update(cantidadBodega:@queso)
    (Inventario.find_by sku:41).update(cantidadBodega:@queso)
    (Inventario.find_by sku:45).update(cantidadBodega:@celulosa)
    (Inventario.find_by sku:47).update(cantidadBodega:@vino)
  end
=end

  def moverA_Despacho #sku, cantidad
    sku = Integer(params[:sku])
    cantidad = Integer(params[:cantidad])
    idDespacho = (Almacen.find_by depacho:true).almacenId
    @id = idDespacho
    #Vemos si tenemos lo suficiente en el almacén de despacho
    key = 'W0B@c0w9.xqo1nQ'
    hmac = HMAC::SHA1.new(key)
    signature = 'GET' + idDespacho
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho}}
    contenido = JSON.parse temp
    i=0
    necesario = cantidad
    while contenido[i].nil? == false do
      sku_ = Integer(contenido[i]["_id"])
      total = Integer(contenido[i]["total"])
      if sku_ == sku
        if total >= cantidad
          necesario = 0
          #Despachamos ya que tenemos lo pedido en el almacen
        else
          necesario = cantidad - total
          
          RestClient::Request.execute(method: :delete, url: 'http://integracion-2016-dev.herokuapp.com/bodega/stock', payload: {:productoId => "572bec06b5df620300b0ff01", :direccion => "internacional", :precio => 2168, :oc => "57128e450606410300c3fbe9"}, headers: {Authorization: 'INTEGRACION grupo1:3xSnVzPkFFo+omcq4zHqAGecYIo='})
          #@necesario = necesario
        end
      else
         necesario = cantidad
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
            temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id, :sku => sku_, :limit => necesario}}
            productos = JSON.parse temp
            @productos = productos
            k = 0
            while k < productos.length
             idProducto = productos[k]["_id"]
             key = 'W0B@c0w9.xqo1nQ'
             hmac = HMAC::SHA1.new(key)
             signature = 'POST' + idProducto + idDespacho
             hmac.update(signature)
             clave = Base64.encode64("#{hmac.digest}")
             RestClient.post  'http://integracion-2016-dev.herokuapp.com/bodega/moveStock', {:productoId => idProducto, :almacenId => idDespacho}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
             necesario -= 1
             if necesario == 0
             break
             end
             puts necesario
            k += 1
            end  
          end
          j += 1
        end
        i += 1
      end  
    end 
  end

=begin
def producir sku, idTrx, cantidad
  #sku = params[:sku]
  #idTrx = params[:trx]
  #cantidad = params[:cantidad]
  key = 'W0B@c0w9.xqo1nQ'
  hmac = HMAC::SHA1.new(key)
  signature = 'PUT' + sku.to_s + cantidad.to_s + idTrx
  hmac.update(signature)
  clave = Base64.encode64("#{hmac.digest}")
  RestClient.put 'http://integracion-2016-dev.herokuapp.com/bodega/fabrica/fabricar', {:sku => sku, :trxId => idTrx, :cantidad => cantidad}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'    
end

def revisarStock
semola = ((Inventario.find_by sku:'19').cantidadBodega).to_i - ((Inventario.find_by sku:'19').cantidadVendida).to_i
levadura = ((Inventario.find_by sku:'27').cantidadBodega).to_i - ((Inventario.find_by sku:'27').cantidadVendida).to_i
celulosa = ((Inventario.find_by sku:'45').cantidadBodega).to_i - ((Inventario.find_by sku:'45').cantidadVendida).to_i
queso = ((Inventario.find_by sku:'40').cantidadBodega).to_i - ((Inventario.find_by sku:'40').cantidadVendida).to_i
vino = ((Inventario.find_by sku:'47').cantidadBodega).to_i - ((Inventario.find_by sku:'47').cantidadVendida).to_i
if semola < 1000
  transaccion = RestClient.put 'http://mare.ing.puc.cl/banco/trx', {:monto => 2027760, :origen => '571262c3a980ba030058ab5b', :destino => '571262aea980ba030058a5d8'}.to_json, :content_type => 'application/json'
  transaccionParseada = JSON.parse transaccion
  idTrx = transaccionParseada["_id"]
  producir 19, idTrx, 1420
end
if levadura < 2000
  transaccion = RestClient.put 'http://mare.ing.puc.cl/banco/trx', {:monto => 2016240, :origen => '571262c3a980ba030058ab5b', :destino => '571262aea980ba030058a5d8'}.to_json, :content_type => 'application/json'
  transaccionParseada = JSON.parse transaccion
  idTrx = transaccionParseada["_id"]
  producir 27, idTrx, 1860
end
if celulosa < 800
  transaccion = RestClient.put 'http://mare.ing.puc.cl/banco/trx', {:monto => 1200000, :origen => '571262c3a980ba030058ab5b', :destino => '571262aea980ba030058a5d8'}.to_json, :content_type => 'application/json'
  transaccionParseada = JSON.parse transaccion
  idTrx = transaccionParseada["_id"]
  producir 45, idTrx, 800
end
if queso < 900
  leche = ((Inventario.find_by sku:'7').cantidadBodega).to_i
  sueroDeLeche = ((Inventario.find_by sku:'41').cantidadBodega).to_i
  if leche < 1000
    #Pedimos leche a otro grupo
  end
  if sueroDeLeche < 800
    #Pedimos a otro grupo
  end
  if leche >= 1000 && sueroDeLeche >= 800
    moverA_Despacho 7, 1000
    moverA_Despacho 41, 1000
    transaccion = RestClient.put 'http://mare.ing.puc.cl/banco/trx', {:monto => 2091600, :origen => '571262c3a980ba030058ab5b', :destino => '571262aea980ba030058a5d8'}.to_json, :content_type => 'application/json'
    transaccionParseada = JSON.parse transaccion
    idTrx = transaccionParseada["_id"]
    producir 40, idTrx, 900
end
end
if vino < 1000
  azucar = ((Inventario.find_by sku:'25').cantidadBodega).to_i
  uva = ((Inventario.find_by sku:'39').cantidadBodega).to_i
  if azucar < 1000
    #pedimos a otro grupo
  end
  if uva < 495
    #pedimos a otro grupo
  end
  if azucar >= 1000 && uva >= 495 && levadura >= 570
    moverA_Despacho 25, 1000
    moverA_Despacho 27, 570
    moverA_Despacho 39, 495
    transaccion = RestClient.put 'http://mare.ing.puc.cl/banco/trx', {:monto => 1921000, :origen => '571262c3a980ba030058ab5b', :destino => '571262aea980ba030058a5d8'}.to_json, :content_type => 'application/json'
    transaccionParseada = JSON.parse transaccion
    idTrx = transaccionParseada["_id"]
    producir 47, idTrx, 1000
  end
end   
end

=end
def revisarRecepcion
  idRecepcion = (Almacen.find_by recepcion:true).almacenId
  almacenesIntermedios = (Almacen.where(recepcion:false)).where(pulmon:false).where(depacho:false)
  key = 'W0B@c0w9.xqo1nQ'
  hmac = HMAC::SHA1.new(key)
  signature = 'GET' + idRecepcion
  hmac.update(signature)
  clave = Base64.encode64("#{hmac.digest}")
  temp = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idRecepcion}}
  productos = JSON.parse temp
  i = 0
  while productos[i].nil? == false do
    sku = Integer(productos[i]["_id"])
    cantidad = Integer(productos[i]["total"])
    signature = 'GET' + idRecepcion + sku.to_s
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    stock = RestClient.get 'http://integracion-2016-dev.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idRecepcion, :sku => sku}}
    stockParseado = JSON.parse stock
    j = 0
    while j < almacenesIntermedios.length
      espacio = (almacenesIntermedios[j].espacioTotal).to_i - (almacenesIntermedios[j].espacioUtilizado).to_i
      if espacio >= cantidad
        k = 0
        almacenId = almacenesIntermedios[j].almacenId
        while stockParseado[k].nil? == false do
          idProducto = stockParseado[k]["_id"]
          key = 'W0B@c0w9.xqo1nQ'
          hmac = HMAC::SHA1.new(key)
          signature = 'POST' + idProducto + almacenId
          hmac.update(signature)
          clave = Base64.encode64("#{hmac.digest}")
          RestClient.post  'http://integracion-2016-dev.herokuapp.com/bodega/moveStock', {:productoId => idProducto, :almacenId => almacenId}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
          k += 1
        end
      end
    j += 1
    end
    i+=1
  end 
end
def despachar# sku, cantidad, cliente
  sku = params[:sku]
  cantidad = params[:cantidad].to_i
  cliente = params[:cliente]
  #sku = sku
  #cantidad = cantidad
  #cliente = cliente
  veces = cantidad/200
  i = 0
  while i <= veces do
  if i == veces
    moverA_Despacho sku, cantidad - 200*veces 
  end
  #else
   # moverA_Despacho sku, 200
  #end
  i += 1
  end
end
end
