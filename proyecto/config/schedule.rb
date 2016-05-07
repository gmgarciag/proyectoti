env :PATH, ENV['PATH']

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :environment, "development"
set :output, "log/cron_log.log"
#

every 1.minute do
	rake "requests:nombresOC"
end

every 2.minute do
	rake "requests:ordenesCompra"
end

every 2.minute do
	rake "requests:actualizarInventario"
end

every 3.minute do
	rake "requests:llenarOrden"
end


# Learn more: http://github.com/javan/whenever
