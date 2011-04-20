$LOAD_PATH << './lib'
require 'database_configuration.rb'
require 'job.rb'

# curata db-ul

jobs = Job.find :all
jobs.each do |j|
  j.destroy
end

# seed

['ruby','event-machine','kittens','monad','monkey'].each do |itm|
  buff = Job.new
  buff.name = itm
  buff.status = 0
  buff.save
end

# end