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

every 20.minute do
	rake "requests:contestarOrden"
end

every 2.hours do
	rake "requests:revisarStock"
end

# Learn more: http://github.com/javan/whenever
