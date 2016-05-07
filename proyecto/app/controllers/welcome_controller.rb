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
  #IDgrupo=(IdGrupo.find_by numeroGrupo: grupoProveedor).idGrupo

#llamada a crear la orden de compra, retorna la orden de compra o error
  @ordenCompra=RestClient.put 'http://mare.ing.puc.cl/oc/crear/', {:cliente => '571262b8a980ba030058ab4f', :proveedor => '571262b8a980ba030058ab4f', :sku => 47, :fechaEntrega => 1463797342000, :cantidad => 4, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'

  end

end

  def index
    #OBTENER LOS ALMACENES

=begin
def obtenerOC

Net::SFTP.start('mare.ing.puc.cl', 'integra1', :password => 'DhY9uFaU') do |sftp|
  r=sftp.dir.foreach("./pedidos") do |entry|
    puts entry.name
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


    #a=r.file.open("./"+entry.name, "r") #do |f|
    #puts a.gets
  #end
  end
end

end

def obtenerOCcompletas



  Net::SFTP.start('mare.ing.puc.cl', 'integra1', :password => 'DhY9uFaU') do |sftp|

    i=Xml.first.id
  totalArchivos = Xml.last.id
  while i<=totalArchivos
    nombre = Xml.find(i).nombreArchivo

  sftp.file.open("./pedidos/"+nombre, "r") do |f|
    f.gets
    f.gets
    @id=f.gets.tr('<id>', '')
    @id=@id.tr('</id>+', '')
    @sku=f.gets.tr('<sku>', '')
    @sku=@sku.tr('</sku>', '').to_i
    @qty=f.gets.tr('<qty>', '')
    @qty=@qty.tr('</qty>', '').to_i

    OrdenCompra.create(idOC: @id, sku: @sku, cantidad: @qty)

    #@numeroOrden = OrdenCompra.find_by(id:14).idOC

    i=i+1
  #Xml.all(:select => "idOC").each do |x|  

    end
  end



  end


  end

=end

  #obtenerOC
   # obtenerOCcompletas
    #comprar(40,10)

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
