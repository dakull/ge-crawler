$LOAD_PATH << './lib'
require 'database_configuration.rb'
require 'job.rb'
require 'preprocessor.rb'

# start
beginning_time = Time.now

  # face cate un proces per job neterminat
  jobs = Job.find_all_by_status(0)
  jobs.each do |job,index|
    buff_process = Process.fork do 
      prep = Preprocessor.new job.name
    end
    puts "## Fork Process #{index} PID: " + buff_process.to_s
  end
  
  # wait to finish
  Process.wait(0)

end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)} sec"

# exit status
puts "Exit " + $?.exitstatus.to_s