$LOAD_PATH << './lib'
require 'database_configuration.rb'
require 'job.rb'

# curata db-ul

jobs = Job.find :all
jobs.each do |j|
  puts "Job name is: #{j.name} and status #{j.status}"
  if j.result then
    j.result.each_with_index do |r,index| 
      puts "***** index #{index}"
      puts r
    end
  end
  puts "****************************"
end

# end