# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#OrdenCompra.create(idOC:1,sku:1,cantidad:1)
#require 'nokogiri'
#require 'net/sftp'
#require 'active_support/core_ext'
#b=1
#Net::SFTP.start('mare.ing.puc.cl', 'integra1', :password => 'DhY9uFaU') do |sftp|
#	sftp.download!("./pedidos", "./home/daniel/Downloads")
	#sftp.dir.foreach("./pedidos") do |entry|
	
	#	q= entry.name
	#	r=sftp.file.open("./pedidos/"+q.to_s, "r") do |f|
	#	puts f.gets

	#	r.close

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

	#end
#end
#end