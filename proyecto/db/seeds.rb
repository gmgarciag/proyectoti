# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
proveedor = Proveedor.create([{ materiaPrima: 'Leche',skuMateriaPrima: 7,skuProducto: 40 ,productoProcesar:'Queso',grupoProveedor: 12,cantidadRequerida: 1000,precio: 1307 },
								{ materiaPrima: 'Levadura',skuMateriaPrima: 27,skuProducto: 47,productoProcesar:'Vino',grupoProveedor: 1,cantidadRequerida: 570,precio: 1376 },
								{ materiaPrima: 'Uva',skuMateriaPrima: 39,skuProducto: 47,productoProcesar:'Vino',grupoProveedor: 7,cantidadRequerida: 495,precio: 1217},
								{ materiaPrima: 'Suero de Leche',skuMateriaPrima: 41,skuProducto: 40,productoProcesar:'Queso',grupoProveedor: 10,cantidadRequerida: 800,precio: 3148 },
								{ materiaPrima: 'Azucar',skuMateriaPrima: 25,skuProducto: 47,productoProcesar:'Vino',grupoProveedor: 6,cantidadRequerida: 1000,precio: 1016 }])

formula = Formula.create([{productoProducir: 'Queso',insumo:'Leche',cantidadRequerida: 1000,loteProducido: 900,skuInsumo: 7,skuProducto: 40},
							{productoProducir: 'Queso',insumo:'Suero de Leche',cantidadRequerida: 800,loteProducido: 900,skuInsumo: 41,skuProducto: 40},
							{productoProducir: 'Vino',insumo:'Uva',cantidadRequerida: 495,loteProducido: 1000,skuInsumo: 39,skuProducto: 47},
							{productoProducir: 'Vino',insumo:'Levadura',cantidadRequerida: 570,loteProducido: 1000,skuInsumo: 27,skuProducto: 47},
							{productoProducir: 'Vino',insumo:'Azucar',cantidadRequerida: 1000,loteProducido: 1000,skuInsumo: 25,skuProducto: 47}])

costoProduccion = CostoProduccion.create([{skuProducto: 19,nombreProducto: 'Sémola',tipoProducto: 'Materia prima',costoProdUnitario: 1428,loteProduccion: 1420,tiempoMedio: 4.033},
											{skuProducto: 27,nombreProducto: 'Levadura',tipoProducto: 'Materia prima',costoProdUnitario: 1084,loteProduccion: 620,tiempoMedio: 2.717},
											{skuProducto: 40,nombreProducto: 'Queso',tipoProducto: 'Producto procesado',costoProdUnitario: 2324,loteProduccion: 900,tiempoMedio: 3.589},
											{skuProducto: 45,nombreProducto: 'Celulosa',tipoProducto: 'Materia prima',costoProdUnitario: 1500,loteProduccion: 800,tiempoMedio: 0.759},
											{skuProducto: 47,nombreProducto: 'Vino',tipoProducto: 'Producto procesado',costoProdUnitario: 1921,loteProduccion: 1000,tiempoMedio: 0.677}])

#idGrupos = IdGrupos.create([{numeroGrupo:'' ,idGrupo:'',idBanco:'',idBodegaRecepcion:''},{},{},{},{},{},{},{},{},{},{},{}])

#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#OrdenCompra.create(idOC:1,sku:1,cantidad:1)
=begin
require 'nokogiri'
require 'net/sftp'
require 'active_support/core_ext'

Net::SFTP.start('mare.ing.puc.cl', 'integra1', :password => 'DhY9uFaU') do |sftp|
	#sftp.dir.foreach("./pedidos") do |entry|
	
		#puts entry.name
		r=sftp.file.open("./pedidos/1461089425694.xml", "r") do |f|
		#puts f.gets
		#@doc = Nokogiri::XML(File.read(r))
		#puts @doc.cdd("id").first.to_s

		 r.xpath("//orden/*").each do |i|

    	puts(i.attribute('id').content)

    	end
		#puts 
		#puts(@doc.xpath("//sku").first)	
		#puts(@doc.xpath("//qty").first)

		r.close

		#3.times{ r.gets }
		#p $_

		#r.close
    	#	puts f.gets
  		#if r != NULL
		#@doc = Nokogiri::XML(File.read(r))
		#			hash=Hash.from_xml(@doc)
		#	puts hash 
	#end
		#puts(@doc.xpath("//id").to_s)
		#puts(@doc.xpath("//sku").to_s)	
		#puts(@doc.xpath("//qty").to_s)
		#idOCs[0].to_s #aqui debemos cortar el string para quedarnos con lo que nos interesa


	 # Orden_compras.create(idOC:id, sku: sku, cantidad:qty)

	end
=end
#end