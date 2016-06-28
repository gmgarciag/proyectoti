require 'rest-client'
require 'rubygems'
require 'base64'
require 'cgi'
require 'hmac-sha1'

namespace :requests do

#aqui debe revisar el saldo
desc "TODO"
task saldo: :environment do
puts "Cron Obtengo Saldo #{Time.now}"
datosCuenta = RestClient.get 'http://integracion-2016-prod.herokuapp.com/banco/cuenta/572aac69bdb6d403005fb04e'
@datosJson = datosCuenta
datosParseado = JSON.parse datosCuenta
cantidad = datosParseado[0]["saldo"].to_s
timeI=Time.now.to_i
timeI=timeI*1000-86400000
Saldo.create(saldo: cantidad, fechaInicio: timeI, fechaFin: Time.now.to_i*1000)
end


desc "TODO"
task nombresOC: :environment do

  	puts "Cron nombresOC #{Time.now}"

	  Net::SFTP.start('moto.ing.puc.cl', 'integra1', :password => 'KPg5RqHE') do |sftp|#cambiar segun ambiente
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

	  Net::SFTP.start('moto.ing.puc.cl', 'integra1', :password => 'KPg5RqHE') do |sftp|#cambiar segun ambiente

	  i=Xml.first.id
	  totalArchivos = Xml.last.id
	  while i<=totalArchivos
	    nombre = Xml.find(i).nombreArchivo

	 	sftp.file.open("./pedidos/"+nombre, "r") do |f|
	    f.gets
	    f.gets
	    @id=f.gets.gsub('<id>', '')
	    @id=@id.gsub('</id>', '')
	    @id=@id.gsub(' ', '')
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
    key = '.k3GBP9YYZmzWCr'#cambiar segun ambiente
    signature = 'GET'
    hmac = HMAC::SHA1.new(key)
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    almacenes = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/almacenes', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'}#cambiar segun ambiente
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
      temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave[i], :content_type => 'application/json', :params => {:almacenId => id}}
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
    (Inventario.find_by sku:41).update(cantidadBodega:@sueroDeLeche)
    (Inventario.find_by sku:45).update(cantidadBodega:@celulosa)
    (Inventario.find_by sku:47).update(cantidadBodega:@vino)


   end
desc "TODO"
task revisarStock: :environment do

		def producir sku, idTrx, cantidad
		  #sku = params[:sku]
		  #idTrx = params[:trx]
		  #cantidad = params[:cantidad]
		  key = '.k3GBP9YYZmzWCr'
		  hmac = HMAC::SHA1.new(key)
		  signature = 'PUT' + sku.to_s + cantidad.to_s + idTrx
		  hmac.update(signature)
		  clave = Base64.encode64("#{hmac.digest}")
		  RestClient.put 'http://integracion-2016-prod.herokuapp.com/bodega/fabrica/fabricar', {:sku => sku, :trxId => idTrx, :cantidad => cantidad}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'    
		 end           
                #metodo que envia la orden de compra para comprar la materia prima cuando no se tiene
    def comprar sku, cantidad, fechaEntrega
     begin
      #sku = (params[:sku]).to_i
      #cantidad = (params[:cantidad]).to_i
      #fechaEntrega = (params[:fechaEntrega]).to_time
      if sku != nil
        ## Debemos preguntar si el grupo tiene la cantidad del producto que necesitamos
        proveedor = (Proveedor.find_by skuMateriaPrima: sku)
        grupoProveedor = proveedor.grupoProveedor
        ## Nos conectamos a la API para consultar el stock que tienen
        respuestaStock = RestClient.get 'http://integra'+grupoProveedor.to_s+'.ing.puc.cl/api/consultar/'+sku.to_s ,{:Content_Type => 'application/json'}
        hashRespuesStock = JSON.parse respuestaStock
        ## Si el stock que tienen es suficiente creamos la orden de compra
        if hashRespuesStock['stock'] >= cantidad
          ## Buscamos el id del grupo proveedor
          idGrupo = (IdGrupoProduccion.find_by numeroGrupo: grupoProveedor).idGrupo
          ## Creamos la orden de compra
          ## Fecha en el formato pedido!
          fechaEnFormato = (fechaEntrega.to_i) * 1000
          precio = proveedor.precio
          ## En produccion
          ordenCompra=RestClient.put 'http://moto.ing.puc.cl/oc/crear/', {:cliente => '572aac69bdb6d403005fb042', :proveedor => idGrupo, :sku => sku, :fechaEntrega => fechaEnFormato, :cantidad => cantidad, :precioUnitario => precio, :canal => 'b2b'}.to_json, :content_type => 'application/json'#ambiente
          ## En desarrollo
          ##ordenCompra=RestClient.put 'http://moto.ing.puc.cl/oc/crear/', {:cliente => '572aac69bdb6d403005fb042', :proveedor => idGrupo, :sku => sku, :fechaEntrega => fechaEnFormato, :cantidad => cantidad, :precioUnitario => precio, :canal => 'b2b'}.to_json, :content_type => 'application/json'
          ## Ya creada la orden de compra tenemos que ir a la aplicacion del grupo proveedor y exigir dicha cantidad
          hashOrdenCompra = JSON.parse ordenCompra
          ## Enviamos al grupo proveedor la orden de compra
          respuestaEnvioOC = RestClient.get 'http://integra'+grupoProveedor.to_s+'.ing.puc.cl/api/oc/recibir/'+hashOrdenCompra['_id'] ,{:Content_Type => 'application/json'}
          hashEnvioOC = JSON.parse respuestaEnvioOC
          ## Esperamos la respuesta y si es positiva tendriamos que guardarla en una base de datos y esperar que nos llegue la factura, que generara el pago automaticamente
          if hashEnvioOC['aceptado'] == true || hashEnvioOC['aceptado'] == 'true' ## ACA SE CAMBIO
            ## Deberiamos guardar en la base de datos que tenemos una orden aceptada
            puts 'se acepto la orden'
            ## Ver bien la insercion!
            Pedido.create(idPedido: hashOrdenCompra['_id'] , creacion: Time.now , proveedor: idGrupo , cantidad: cantidad.to_i , despachado: 0 , fechaEntrega: fechaEntrega.to_i , estado: 'Aceptada' , transaccion: false)
          else
            ## 
            puts 'no me lee que la acepto'
            Pedido.create(idPedido: hashOrdenCompra['_id'] , creacion: Time.now , proveedor: idGrupo , cantidad: cantidad.to_i , despachado: 0 , fechaEntrega: fechaEntrega.to_i , estado: 'Rechazada' , transaccion: false)
          end
          ## Luego hay que esperar que el cliente nos despache
        else

        end
      end
     rescue
      ## No compra si se cae, deberia alomejor guardar en el log la informacion por la que se cayo
     end

     end
  
    def moverInsumosDespacho sku, cantidad
    #sku = Integer(params[:sku])
    #cantidad = Integer(params[:cantidad])
    #oc = params[:oc]
    idDespacho = (Almacen.find_by depacho:true).almacenId
    cantidadBodega = ((Inventario.find_by sku: sku).cantidadBodega).to_i
    cantidadBodega = cantidadBodega - cantidad
    (Inventario.find_by sku: sku).update(cantidadBodega: cantidadBodega)
    #Vemos si tenemos lo suficiente en el almacén de despacho
    key = '.k3GBP9YYZmzWCr'
    hmac = HMAC::SHA1.new(key)
    signature = 'GET' + idDespacho
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho}}
    contenido = JSON.parse temp
    i=0
    necesario = cantidad
    while contenido[i].nil? == false do
      sku_ = Integer(contenido[i]["_id"])
      total = Integer(contenido[i]["total"])
      if sku_ == sku

        if total >= cantidad
          necesario = 0
        else
          necesario = cantidad - total
        end
      end
    end
   while necesario > 0 do
      i = Almacen.first.id
      #recorremos los almacenes buscando el producto
      nAlmacenes = Almacen.last.id
      while i <= nAlmacenes 
        id = Almacen.find(i).almacenId
        key = '.k3GBP9YYZmzWCr'
        hmac = HMAC::SHA1.new(key)
        signature = 'GET' + id
        hmac.update(signature)
        clave = Base64.encode64("#{hmac.digest}")
        temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id}}
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
              if necesario != 0
                puts necesario
                temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id, :sku => sku_, :limit => necesario}}
                productos = JSON.parse temp
                @productos = productos
                puts productos
                k = 0
                while k < productos.length
                  idProducto = productos[k]["_id"]
                  key = '.k3GBP9YYZmzWCr'
                  hmac = HMAC::SHA1.new(key)
                  signature = 'POST' + idProducto + idDespacho
                  hmac.update(signature)
                  clave = Base64.encode64("#{hmac.digest}")
                  RestClient.post  'http://integracion-2016-prod.herokuapp.com/bodega/moveStock', {:productoId => idProducto, :almacenId => idDespacho}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
                  k += 1
               end
               necesario -= k
             end  
           end
           j += 1
         end
         i += 1
       end  
    end
   end

   puts "Cron Revisar Stock #{Time.now}"

		semola = ((Inventario.find_by sku:'19').cantidadBodega).to_i - ((Inventario.find_by sku:'19').cantidadVendida).to_i
		levadura = ((Inventario.find_by sku:'27').cantidadBodega).to_i - ((Inventario.find_by sku:'27').cantidadVendida).to_i
		celulosa = ((Inventario.find_by sku:'45').cantidadBodega).to_i - ((Inventario.find_by sku:'45').cantidadVendida).to_i
		queso = ((Inventario.find_by sku:'40').cantidadBodega).to_i - ((Inventario.find_by sku:'40').cantidadVendida).to_i
		vino = ((Inventario.find_by sku:'47').cantidadBodega).to_i - ((Inventario.find_by sku:'47').cantidadVendida).to_i
                key = '.k3GBP9YYZmzWCr'
	        hmac = HMAC::SHA1.new(key)
	        signature = 'GET'
		hmac.update(signature)
		clave = Base64.encode64("#{hmac.digest}")
                cuentaFabrica = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/fabrica/getCuenta', :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json' 
                puts cuentaFabrica
                puts semola	
    if semola < 1000
                
		  transaccion = RestClient.put 'http://moto.ing.puc.cl/banco/trx', {:monto => 2027760, :origen => '572aac69bdb6d403005fb04e', :destino => '572aac69bdb6d403005fb040'}.to_json, :content_type => 'application/json'## ver que onda el ambiente y los ids
		  transaccionParseada = JSON.parse transaccion
		  idTrx = transaccionParseada["_id"]
		  producir 19, idTrx, 1420
		end
		if levadura < 2000
		  transaccion = RestClient.put 'http://moto.ing.puc.cl/banco/trx', {:monto => 4032480, :origen => '572aac69bdb6d403005fb04e', :destino => '572aac69bdb6d403005fb040'}.to_json, :content_type => 'application/json'
		  transaccionParseada = JSON.parse transaccion
		  idTrx = transaccionParseada["_id"]
		  producir 27, idTrx, 3720
		end
		if celulosa < 800
		  transaccion = RestClient.put 'http://moto.ing.puc.cl/banco/trx', {:monto => 1200000, :origen => '572aac69bdb6d403005fb04e', :destino => '572aac69bdb6d403005fb040'}.to_json, :content_type => 'application/json'
		  transaccionParseada = JSON.parse transaccion
		  idTrx = transaccionParseada["_id"]
		  producir 45, idTrx, 800
		end
		if queso < 900
		  leche = ((Inventario.find_by sku:'7').cantidadBodega).to_i
		  sueroDeLeche = ((Inventario.find_by sku:'41').cantidadBodega).to_i
		  if leche < 1000
                    time = Time.now + 4.hours
		    comprar 7, 1000, time
		  end
		  if sueroDeLeche < 800
                    time = Time.now + 4.hours
		    comprar 41, 800, time
		  end
		  if leche >= 1000 && sueroDeLeche >= 800
		    moverInsumosDespacho 7, 1000
		    moverInsumosDespacho 41, 800
		    transaccion = RestClient.put 'http://moto.ing.puc.cl/banco/trx', {:monto => 2091600, :origen => '572aac69bdb6d403005fb04e', :destino => '572aac69bdb6d403005fb040'}.to_json, :content_type => 'application/json'
		    transaccionParseada = JSON.parse transaccion
		    idTrx = transaccionParseada["_id"]
		    producir 40, idTrx, 900
		end
		end
		if vino < 1000
		  azucar = ((Inventario.find_by sku:'25').cantidadBodega).to_i
		  uva = ((Inventario.find_by sku:'39').cantidadBodega).to_i
		  if azucar < 1000
                    time = Time.now + 4.hours
		    comprar 25, 1000, time
		  end
		  if uva < 495
                    time = Time.now + 4.hours
		    #comprar 39, 495, time
		  end
		  if azucar >= 1000 && uva >= 495 && levadura >= 570
		    moverInsumosDespacho 25, 1000
		    moverInsumosDespacho 27, 570
		    moverInsumosDespacho 39, 495
		    transaccion = RestClient.put 'http://moto.ing.puc.cl/banco/trx', {:monto => 1921000, :origen => '572aac69bdb6d403005fb04e', :destino => '572aac69bdb6d403005fb040'}.to_json, :content_type => 'application/json'
		    transaccionParseada = JSON.parse transaccion
		    idTrx = transaccionParseada["_id"]
		    producir 47, idTrx, 1000
		  end
		end   

   end
desc "TODO"
task llenarOrden: :environment do

  	puts "Cron Llenar Orden #{Time.now}"

	  ordens = OrdenCompra.all
	  ordens.each do |orden|####<<<<<<<<<<------------
	  idOrden = orden.idOC
	  temp = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' +idOrden.strip 
	  ordenParseada = JSON.parse temp
	  id = ordenParseada[0]["_id"]####<<<<<<<<----------------
	  fechaCreacion = ordenParseada[0]["created_at"]
	  canal = ordenParseada[0]["canal"]
	  cliente = ordenParseada[0]["cliente"]
	  sku = ordenParseada[0]["sku"]
	  cantidad = ordenParseada[0]["cantidad"]
	  despachada = 0
	  precioUnitario = ordenParseada[0]["precioUnitario"]
	  fechaEntrega = ordenParseada[0]["fechaEntrega"]
	  #estado = ordenParseada[0]["estado"]
	  estado="creada"
	  rechazo =""
	  anulacion = ""
	  idFactura = ""
	  Orden.create(idOrden:id, fechaCreacion:fechaCreacion, canal:canal, cliente:cliente, sku:sku, cantidad:cantidad, despachada:despachada, precioUnitario:precioUnitario, fechaEntrega:fechaEntrega, estado:estado, rechazo:rechazo, anulacion:anulacion, idFactura:idFactura) 
    end

    end
desc "TODO"
task contestarOrden: :environment do

 puts "Cron Contestar Orden #{Time.now}"

  ordenesServidor = Orden.where(cliente: "internacional")
  time = Time.now
  #puts time
  #milisegundos = time.to_formatted_s(:number)
  ordenesServidor.each do |orden|
  fecha = orden.fechaEntrega
  estado = orden.estado
  #puts fecha
  idOrden = orden.idOrden
  #Revisamos que no haya pasado la fecha de despacho
  if fecha <= time && estado != 'aceptada' && estado != 'despachada'  && estado!= 'rechazada' && estado != 'LPD'
   (Orden.find_by idOrden: idOrden).update(estado: "rechazada", rechazo: "expiró la fecha de entrega")
  RestClient.post  'http://moto.ing.puc.cl/oc/rechazar/' + idOrden.strip, {:id => idOrden, :rechazo => "expiró la fecha de entrega"}.to_json, :content_type => 'application/json' 
  end

  end
  #Revisamos que el precio sea mayor o igual al que pedimos
  ordenesServidor.each do |orden|
    sku = orden.sku
    precio = orden.precioUnitario
    idOrden = orden.idOrden
    precioMinimo = (NuestroProducto.find_by sku: sku).precio
    if precio < precioMinimo
      (Orden.find_by idOrden: idOrden).update(estado: "rechazada" , rechazo: "el precio especificado es menor al pactado")
      RestClient.post  'http://moto.ing.puc.cl/oc/rechazar/' + idOrden.strip, {:id => idOrden, :rechazo => "El precio especificado es menor al pactado"}.to_json, :content_type => 'application/json'
    end
  end
  ordenesPorContestar = ordenesServidor.where(estado: "creada")
  ordenesPorContestar.each do |orden|
     sku = orden.sku
     cantidad = orden.cantidad
     idOrden = orden.idOrden
     disponible = ((Inventario.find_by sku: sku).cantidadBodega).to_i - ((Inventario.find_by sku: sku).cantidadVendida).to_i
     #puts disponible

     if cantidad.to_i <= disponible #Aceptamos la orden
     (Orden.find_by idOrden: idOrden).update(estado: "aceptada")
     RestClient.post  'http://moto.ing.puc.cl/oc/recepcionar/' + idOrden.strip, {:id => idOrden}.to_json, :content_type => 'application/json'
     cantidadVendida = (Inventario.find_by sku: sku).cantidadVendida.to_i
     cantidadVendida += cantidad.to_i
     (Inventario.find_by sku: sku).update(cantidadVendida: cantidadVendida)
     factura = RestClient.put 'http://moto.ing.puc.cl/facturas/', {:oc => idOrden}.to_json, :content_type => 'application/json'
     facturaParseada = JSON.parse factura
     creado = facturaParseada['created_at']
     cliente = facturaParseada['cliente']
     proveedor = facturaParseada['proveedor']
     total = facturaParseada['total']
     id = facturaParseada['_id']
     estado = facturaParseada['estado']
     Factura.create(creado:creado, cliente:cliente, proveedor:proveedor, total:total, idFactura:id, estado:estado)
     (Orden.find_by idOrden: idOrden).update(estado: "LPD")


     elsif cantidad.to_i > disponible #Hay falta de stock
      (Orden.find_by idOrden: idOrden).update(estado: "rechazada")
      (Orden.find_by idOrden: idOrden).update(rechazo: "no hay stock")

      RestClient.post  'http://moto.ing.puc.cl/oc/rechazar/' + idOrden.strip, {:id => idOrden, :rechazo => "No hay stock"}.to_json, :content_type => 'application/json'
     end
  end
  
 end
 #despacha tanto a internacional como a B2B
desc "TODO"
task despachar: :environment do

  puts "Cron Despachar #{Time.now}"

  ##### aqui debe pegarse el metodo 'mover A despacho' que actualmente esta en logica controller
  def moverA_Despacho oc
    #sku = Integer(params[:sku])
    #cantidad = Integer(params[:cantidad])
    #oc = params[:oc]
    idDespacho = (Almacen.find_by depacho:true).almacenId
    @id = idDespacho
    sku = (((Orden.find_by idOrden: oc).sku).strip).to_i
    cantidad = (((Orden.find_by idOrden: oc).cantidad).strip).to_i
    puts cantidad
    cliente = (Orden.find_by idOrden: oc).cliente
    cantidadBodega = ((Inventario.find_by sku: sku).cantidadBodega).to_i
    cantidadBodega = cantidadBodega - cantidad
    (Inventario.find_by sku: sku).update(cantidadBodega: cantidadBodega)
    cantidadVendida = ((Inventario.find_by sku: sku).cantidadVendida).to_i
    cantidadVendida = cantidadVendida - cantidad
    (Inventario.find_by sku: sku).update(cantidadVendida: cantidadVendida)
   # producto = ((Inventario.find_by sku: sku).cantidadBodega).to_i - ((Inventario.find_by sku: sku).cantidadVendida).to_i
   # if sku == 19
   # StockItem.find(1).update(count_on_hand:producto)
   # elsif sku == 27
   # StockItem.find(2).update(count_on_hand:producto)
   # elsif sku == 40
   # StockItem.find(3).update(count_on_hand:producto)
   # elsif sku == 45
   # StockItem.find(4).update(count_on_hand:producto)
   # elsif sku == 47
   # StockItem.find(5).update(count_on_hand:producto)
 # end
    if cliente == 'internacional'
    #Vemos si tenemos lo suficiente en el almacén de despacho
    key = '.k3GBP9YYZmzWCr'
    hmac = HMAC::SHA1.new(key)
    signature = 'GET' + idDespacho
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho}}
    contenido = JSON.parse temp
    i=0
    necesario = cantidad
    restante = cantidad
    while contenido[i].nil? == false do
      sku_ = Integer(contenido[i]["_id"])
      total = Integer(contenido[i]["total"])
      if sku_ == sku
       puts 'ehtra aca'
        if total >= cantidad
          necesario = 0
          restante = 0
          while cantidad > 0
          key = '.k3GBP9YYZmzWCr'
          hmac = HMAC::SHA1.new(key)
          signature = 'GET' + idDespacho + sku.to_s
          hmac.update(signature)
          clave = Base64.encode64("#{hmac.digest}")
          stock = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => cantidad}}
          stockParseado = JSON.parse stock
          puts stockParseado.length
          k = 0
          puts cantidad
          while k < stockParseado.length
            idProducto = stockParseado[k]["_id"]
            direccion = 'internacional'
            orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' + oc
            ordenParseada = JSON.parse orden
            precio = ordenParseada[0]["precioUnitario"]
            key = '.k3GBP9YYZmzWCr'
            hmac = HMAC::SHA1.new(key)
            signature = 'DELETE' + idProducto + direccion + precio.to_s + oc
            hmac.update(signature)
            clave = Base64.encode64("#{hmac.digest}")
            RestClient::Request.execute(method: :delete, url: 'http://integracion-2016-prod.herokuapp.com/bodega/stock', payload: {:productoId => idProducto, :direccion => direccion, :precio => precio, :oc => oc}, headers: {Authorization: 'INTEGRACION grupo1:'+clave})
            k += 1
            end
          cantidad -= k
          end
            else
                necesario = cantidad - total
                restante = cantidad - total
                while total > 0
                #Despachamos lo que teniamos en despacho
                key = '.k3GBP9YYZmzWCr'
                hmac = HMAC::SHA1.new(key)
                signature = 'GET' + idDespacho + sku.to_s
                hmac.update(signature)
                clave = Base64.encode64("#{hmac.digest}")
                stock = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => total}}
                stockParseado = JSON.parse stock
                puts stockParseado.length
                k = 0
                while k < stockParseado.length
                  idProducto = stockParseado[k]["_id"]
                  direccion = 'internacional'
                  orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' + oc
                  ordenParseada = JSON.parse orden
                  precio = ordenParseada[0]["precioUnitario"]
                  key = '.k3GBP9YYZmzWCr'
                  hmac = HMAC::SHA1.new(key)
                  signature = 'DELETE' + idProducto + direccion + precio.to_s + oc
                  hmac.update(signature)
                  clave = Base64.encode64("#{hmac.digest}")
                  RestClient::Request.execute(method: :delete, url: 'http://integracion-2016-prod.herokuapp.com/bodega/stock', payload: {:productoId => idProducto, :direccion => direccion, :precio => precio, :oc => oc}, headers: {Authorization: 'INTEGRACION grupo1:'+clave})
                  k += 1
                  end
                total -= k
                end
                #@necesario = necesario
              end
            else
               #necesario = cantidad
               #restante = cantidad
            end
            i += 1
          end
          while necesario > 0 do
            i = Almacen.first.id
            #recorremos los almacenes buscando el producto
            nAlmacenes = Almacen.last.id
            while i <= nAlmacenes 
              id = Almacen.find(i).almacenId
              key = '.k3GBP9YYZmzWCr'
              hmac = HMAC::SHA1.new(key)
              signature = 'GET' + id
              hmac.update(signature)
              clave = Base64.encode64("#{hmac.digest}")
              temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id}}
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
                  if necesario != 0
                  puts necesario
                  temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id, :sku => sku_, :limit => necesario}}
                  productos = JSON.parse temp
                  @productos = productos
                  puts productos
                  k = 0
                  while k < productos.length
                   idProducto = productos[k]["_id"]
                   key = '.k3GBP9YYZmzWCr'
                   hmac = HMAC::SHA1.new(key)
                   signature = 'POST' + idProducto + idDespacho
                   hmac.update(signature)
                   clave = Base64.encode64("#{hmac.digest}")
                   RestClient.post  'http://integracion-2016-prod.herokuapp.com/bodega/moveStock', {:productoId => idProducto, :almacenId => idDespacho}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
                  k += 1
                  end
                  necesario -= k
                  end  
                end
                j += 1
              end
              i += 1
            end  
    end
    #Enviamos lo restante
   while restante > 0
   key = '.k3GBP9YYZmzWCr'
   hmac = HMAC::SHA1.new(key)
   signature = 'GET' + idDespacho + sku.to_s
   hmac.update(signature)
   clave = Base64.encode64("#{hmac.digest}")
   stock = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => restante}}
   stockParseado = JSON.parse stock
   puts stockParseado.length
   k = 0
   while k < stockParseado.length
   idProducto = stockParseado[k]["_id"]
   direccion = 'internacional'
   orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' + oc
   ordenParseada = JSON.parse orden
   precio = ordenParseada[0]["precioUnitario"]
   key = '.k3GBP9YYZmzWCr'
   hmac = HMAC::SHA1.new(key)
   signature = 'DELETE' + idProducto + direccion + precio.to_s + oc
   hmac.update(signature)
   clave = Base64.encode64("#{hmac.digest}")
   RestClient::Request.execute(method: :delete, url: 'http://integracion-2016-prod.herokuapp.com/bodega/stock', payload: {:productoId => idProducto, :direccion => direccion, :precio => precio, :oc => oc}, headers: {Authorization: 'INTEGRACION grupo1:'+clave})
   k += 1
   end
   restante -= k
   end

   #(Orden.find_by idOrden: oc).update(estado: "despachada")
   #Aquí termina el if internacional 
   else
    almacenRecepcion = (IdGrupoProduccion.find_by idGrupo: cliente).idBodegaRecepcion
    #Vemos si hay lo suficiente en el almacén de despacho
    key = '.k3GBP9YYZmzWCr'
    hmac = HMAC::SHA1.new(key)
    signature = 'GET' + idDespacho
    hmac.update(signature)
    clave = Base64.encode64("#{hmac.digest}")
    temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho}}
    contenido = JSON.parse temp
    i=0
    necesario = cantidad
    restante = cantidad
    while contenido[i].nil? == false do
      sku_ = Integer(contenido[i]["_id"])
      total = Integer(contenido[i]["total"])
      if sku_ == sku
        if total >= cantidad
          necesario = 0
          restante = 0
          while cantidad > 0
          key = '.k3GBP9YYZmzWCr'
          hmac = HMAC::SHA1.new(key)
          signature = 'GET' + idDespacho + sku.to_s
          hmac.update(signature)
          clave = Base64.encode64("#{hmac.digest}")
          stock = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => cantidad}}
          stockParseado = JSON.parse stock
          puts stockParseado.length
          k = 0
          puts cantidad
          while k < stockParseado.length
            idProducto = stockParseado[k]["_id"]
            orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' + oc
            ordenParseada = JSON.parse orden
            precio = ordenParseada[0]["precioUnitario"]
            key = '.k3GBP9YYZmzWCr'
            hmac = HMAC::SHA1.new(key)
            signature = 'POST' + idProducto + almacenRecepcion
            hmac.update(signature)
            clave = Base64.encode64("#{hmac.digest}")
            RestClient.post  'http://integracion-2016-prod.herokuapp.com/bodega/moveStockBodega', {:productoId => idProducto, :almacenId => almacenRecepcion, :oc => oc, :precio => precio}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
            k += 1
            end
          cantidad -= k
          end
        else
          necesario = cantidad - total
          restante = cantidad - total
          while total > 0
          #Despachamos lo que teniamos en despacho
          key = '.k3GBP9YYZmzWCr'
          hmac = HMAC::SHA1.new(key)
          signature = 'GET' + idDespacho + sku.to_s
          hmac.update(signature)
          clave = Base64.encode64("#{hmac.digest}")
          stock = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => total}}
          stockParseado = JSON.parse stock
          puts stockParseado.length
          k = 0
          while k < stockParseado.length
            idProducto = stockParseado[k]["_id"]
            orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' + oc
            ordenParseada = JSON.parse orden
            precio = ordenParseada[0]["precioUnitario"]
            key = '.k3GBP9YYZmzWCr'
            hmac = HMAC::SHA1.new(key)
            signature = 'POST' + idProducto + almacenRecepcion
            hmac.update(signature)
            clave = Base64.encode64("#{hmac.digest}")
            RestClient.post  'http://integracion-2016-prod.herokuapp.com/bodega/moveStockBodega', {:productoId => idProducto, :almacenId => almacenRecepcion, :oc => oc, :precio => precio}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
            k += 1
            end
          total -= k
          end
          #@necesario = necesario
        end
      else
         necesario = cantidad
         restante = cantidad
      end
      i += 1
    end
    while necesario > 0 do
      i = Almacen.first.id
      #recorremos los almacenes buscando el producto
      nAlmacenes = Almacen.last.id
      while i <= nAlmacenes 
        id = Almacen.find(i).almacenId
        key = '.k3GBP9YYZmzWCr'
        hmac = HMAC::SHA1.new(key)
        signature = 'GET' + id
        hmac.update(signature)
        clave = Base64.encode64("#{hmac.digest}")
        temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/skusWithStock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id}}
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
            if necesario != 0
            temp = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => id, :sku => sku_, :limit => necesario}}
            productos = JSON.parse temp
            @productos = productos
            puts productos
            k = 0
            while k < productos.length
             idProducto = productos[k]["_id"]
             key = '.k3GBP9YYZmzWCr'
             hmac = HMAC::SHA1.new(key)
             signature = 'POST' + idProducto + idDespacho
             hmac.update(signature)
             clave = Base64.encode64("#{hmac.digest}")
             RestClient.post  'http://integracion-2016-prod.herokuapp.com/bodega/moveStock', {:productoId => idProducto, :almacenId => idDespacho}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
            k += 1
            end
            necesario -= k
            end  
          end
          j += 1
        end
        i += 1
      end  
    end
    #Enviamos lo restante
   while restante > 0
   key = '.k3GBP9YYZmzWCr'
   hmac = HMAC::SHA1.new(key)
   signature = 'GET' + idDespacho + sku.to_s
   hmac.update(signature)
   clave = Base64.encode64("#{hmac.digest}")
   stock = RestClient.get 'http://integracion-2016-prod.herokuapp.com/bodega/stock', {:Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json', :params => {:almacenId => idDespacho, :sku => sku, :limit => restante}}
   stockParseado = JSON.parse stock
   puts stockParseado.length
   k = 0
   while k < stockParseado.length
   idProducto = stockParseado[k]["_id"]
   orden = RestClient.get 'http://moto.ing.puc.cl/oc/obtener/' + oc
   ordenParseada = JSON.parse orden
   precio = ordenParseada[0]["precioUnitario"]
   key = '.k3GBP9YYZmzWCr'
   hmac = HMAC::SHA1.new(key)
   signature = 'POST' + idProducto + almacenRecepcion
   hmac.update(signature)
   clave = Base64.encode64("#{hmac.digest}")
   RestClient.post 'http://integracion-2016-prod.herokuapp.com/bodega/moveStockBodega', {:productoId => idProducto, :almacenId => almacenRecepcion, :oc => oc, :precio => precio}.to_json, :Authorization => 'INTEGRACION grupo1:' + clave, :content_type => 'application/json'
   k += 1
   end
   restante -= k
   end
    #(Orden.find_by idOrden: oc).update(estado: "despachada")
   end

    end

 (Orden.all).each do |orden|

 if (orden.estado == "LPD") #&& (orden.fechaEntrega > Time.now))
  moverA_Despacho(orden.idOrden)
	idOrden = orden.id
	(Orden.find_by id: idOrden).update(estado: "despachada")
			## llamar a metodo moverAdespacho

		end
	 end 


 end

end
