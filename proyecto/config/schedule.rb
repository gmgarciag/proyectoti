env :PATH, ENV['PATH']

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :environment, "production"
set :output, "log/cron_log.log"
#
every 3.minute do
	rake "requestsOfertas:revisarOfertas" 
end
every 2.minute do
        rake "requests:actualizarOrdenes"
end
every 10.minute do
	rake "requests:nombresOC"
end

every 15.minute do
	rake "requests:ordenesCompra"
end

every 5.minute do
	rake "requests:actualizarInventario"
end

every 15.minute do
	rake "requests:llenarOrden"
end

every 2.hours do
	rake "requests:despachar"
end

every 4.hours do
	rake "requests:contestarOrden"
end

every 2.hours do
	rake "requests:revisarStock"
end

every 1.day, :at => '02:03 pm' do
       rake "requests:revisarStock"
end

every 1.day, :at => '00:27 am' do #revisa el saldo al finalizar el dia
		rake "requests:saldo"
end

every 1.day, :at => '23:59 pm' do #revisa el stock al final del día
      rake "requests:contarStock"
end

#every 1.day, :at => '05:00 am' do
#      rake "requests:contestarOrden"
#end
# Learn more: http://github.com/javan/whenever
