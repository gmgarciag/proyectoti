namespace :requests do
  desc "TODO"
  task nombresOC: :environment do

  	#logger.debug("Cron test #{Time.now}")
  	#puts "Cron nombresOC #{Time.now}"

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

	#logger.debug("Cron test #{Time.now}")
	#puts "Cron ordenesCompra #{Time.now}"

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
	    i=i+1

	    end
	  end
	  end


  end

end
