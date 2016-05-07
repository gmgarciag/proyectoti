require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'

namespace :requests do

  desc "TODO"
  task nombresOC: :environment do

  	#logger.debug("Cron test #{Time.now}")
  	puts "Cron nombresOC #{Time.now}"

	Net::SFTP.start('mare.ing.puc.cl', 'integra1', :password => 'DhY9uFaU') do |sftp|
	  r=sftp.dir.foreach("./pedidos") do |entry|
	    #puts entry.name
	    #busca si el archivo ya existia en las ordenes de compra y lo mete a la base de datos
	    begin
	    if ((Xml.find_by nombreArchivo: entry.name).nombreArchivo == nil && (entry.name!= '.' && entry.name!= '..'))
	          Xml.create(nombreArchivo: entry.name)
	    end 
	    rescue
	      if(entry.name != '.' && entry.name!= '..')
	      Xml.create(nombreArchivo: entry.name)
	    end
	    end
	  end
	end


  end

  desc "TODO"
  task ordenesCompra: :environment do

	puts "Cron ordenesCompra #{Time.now}"

	  Net::SFTP.start('mare.ing.puc.cl', 'integra1', :password => 'DhY9uFaU') do |sftp|

	  i=Xml.first.id
	  totalArchivos = Xml.last.id
	  while i<=totalArchivos
	    nombre = Xml.find(i).nombreArchivo

	 	sftp.file.open("./pedidos/"+nombre, "r") do |f|
	    f.gets
	    f.gets
	    @id=f.gets.gsub('<id>', '')
	    @id=@id.gsub('</id>', '')
	    @sku=f.gets.gsub('<sku>', '')
	    @sku=@sku.gsub('</sku>', '').to_i
	    @qty=f.gets.gsub('<qty>', '')
	    @qty=@qty.gsub('</qty>', '').to_i

	    OrdenCompra.create(idOC: @id, sku: @sku, cantidad: @qty)
	    i=i+1

	    end
	  end
	  end


  end


  desc "TODO"
  task actualizarInventario: :environment do

	puts "Cron Actualiza Inventario #{Time.now}"
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



  desc "TODO"
  task revisarStock: :environment do

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

  		puts "Cron Revisar Stock #{Time.now}"

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


end
