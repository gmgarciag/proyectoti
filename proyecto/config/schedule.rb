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
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end

#every 1.minute do
#	command "echo 'logueando'"

#end

#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
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
	rake "requests:revisarStock"
end
# Learn more: http://github.com/javan/whenever
