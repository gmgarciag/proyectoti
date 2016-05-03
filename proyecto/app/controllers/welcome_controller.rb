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

  #obtenerOC
    obtenerOCcompletas
    comprar(40,10)
  end

  def comprar(_sku,cantidad)

    if _sku != nil
 
      grupoProveedor=(Proveedor.find_by skuProducto: _sku).grupoProveedor
      puts grupoProveedor
      #asumo que ya tengo plata
      #obtengo el ID del grupo
      idGrupo=(IdGrupo.find_by numeroGrupo: grupoProveedor).idGrupo

      #llamada a crear la orden de compra, retorna la orden de compra o error
      @ordenCompra=RestClient.put 'http://mare.ing.puc.cl/oc/crear/', {:cliente => '571262b8a980ba030058ab4f', :proveedor => idGrupo, :sku => 47, :fechaEntrega => 1463797342000, :cantidad => 4, :precioUnitario => 7244, :canal => 'b2b'}.to_json, :content_type => 'application/json'

    end

 end
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

end
