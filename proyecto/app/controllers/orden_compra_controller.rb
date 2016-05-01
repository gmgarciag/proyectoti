#uno de los metodos probados para obtener las ordenes de compra sftp

class OrdenCompraController < ApplicationController
require 'net/sftp'

Net::SFTP.start('mare.ing.puc.cl', 'integra1', :password => 'DhY9uFaU') do |sftp|
	sftp.dir.foreach("./") do |entry|
	  puts entry.longname
end 
end

#Orden_compras.create(idOC: , sku: , cantidad:)

end
