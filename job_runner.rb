$LOAD_PATH << './lib'
require 'database_configuration.rb'
require 'job.rb'
require 'preprocessor.rb'

# Start
beginning_time = Time.now

  # Process forking
  jobs = Job.find_all_by_status(0)
  jobs.each do |job,index|
    buff_process = Process.fork do
      prep = Preprocessor.new job.name
    end
    puts "## Fork Process #{index} PID: " + buff_process.to_s
  end

  Process.wait(0)

end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)} sec"

# exit status
puts "Exit " + $?.exitstatus.to_s