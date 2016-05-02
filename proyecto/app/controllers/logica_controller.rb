class LogicaController < ApplicationController
require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'
def contestar
  idOrden = params[:idOrden]
  orden = RestClient.get 'http://mare.ing.puc.cl/oc/obtener/' +idOrden 
  ordenParseada = JSON.parse orden
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
    Inventario.create(sku:19, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:27, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:40, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:45, cantidadBodega:0, cantidadVendida:0)
    Inventario.create(sku:47, cantidadBodega:0, cantidadVendida:0)
    #Contamos lo que hay en cada almacén
    i = 0
    until i > nAlmacenes do
      productosParseado = JSON.parse productos[i]
      j = 0
      while productosParseado[j].nil? == false do
      #if productosParseado[j].nil? == false
      id = Integer(productosParseado[0]["_id"])
      cantidad = Integer(productosParseado[0]["total"])
      if id == 19
        @semola += cantidad
      elsif id == 27
        @levadura += cantidad
      elsif id == 10
        #@otro += cantidad
      elsif id == 40
        @queso += cantidad
      elsif id == 45
        @celulosa += cantidad
      elsif id == 47
        @vino += cantidad
      end
      j += 1
      end
      i += 1
    end
    (Inventario.find_by sku:19).update(cantidadBodega:@semola, cantidadVendida:0)
    (Inventario.find_by sku:27).update(cantidadBodega:@levadura, cantidadVendida:0)
    (Inventario.find_by sku:40).update(cantidadBodega:@queso, cantidadVendida:0)
    (Inventario.find_by sku:45).update(cantidadBodega:@celulosa, cantidadVendida:0)
    (Inventario.find_by sku:47).update(cantidadBodega:@vino, cantidadVendida:0)
  end
end
