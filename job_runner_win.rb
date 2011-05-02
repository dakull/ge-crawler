$LOAD_PATH << './lib'
require 'database_configuration.rb'
require 'job.rb'
require 'preprocessor.rb'

# start
beginning_time = Time.now

  jobs = Job.find_all_by_status(0)
  jobs.each do |job,index|
    prep = Preprocessor.new job.name
  end
  
end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)} sec"