#uno de los metodos probados para obtener las ordenes de compra sftp

class OrdenCompraController < ApplicationController
require 'net/sftp'

def conseguirOrdenes

Net::SFTP.start('moto.ing.puc.cl', 'integra1', :password => 'KPg5RqHE') do |sftp|#cambiar prod/dev
	sftp.dir.foreach("./pedidos") do |entry|
	  puts entry.name
end 
end

end

#Orden_compras.create(idOC: , sku: , cantidad:)

end
