# TODO:
# 70 pg
# mutatie - selectez un link care nu contine keywords
$LOAD_PATH << './lib'
$LOAD_PATH << './lib/customlogger'
$LOAD_PATH << './lib/database'
$LOAD_PATH << './lib/uriio'

require 'database_configuration.rb'
require 'job.rb'
require 'genetic_algorithm.rb'
require 'genetic_algorithms.rb'
require 'preprocessor.rb'
require 'postprocessor.rb'
require 'postprocessor_mutation.rb'

require 'json'

#ActiveRecord::Base.connection.reconnect!
#ActiveRecord::Base.establish_connection

counter = 0
# infinite loop
loop do
  # sleep for 500ms
  sleep 0.500
  puts "In loop: " + (counter += 1).to_s
  begin
    jobs = Database::Job.find_all_by_status(0)
    jobs.each do |job,index|
      puts "Processing job: " + job.name
      # time to run
      beginning_time = Time.now
      # init algo
      ga_buff = GeneticAlgorithm.new job.name, job.settings[:iterations], &ge_mark_i
      ga_buff.probability_of_crossover = Float(job.settings[:crossover_p])
      ga_buff.probability_of_mutation = Float(job.settings[:mutation_p])
      ga_buff.job = job
      # put job in processing mode
      job.result = nil
      job.status = 2
      job.save    
      ga_buff.run_algorithm
      # job done
      end_time = Time.now
      # save results
      job.result = {
                     :links => ga_buff.result, 
                     :populations => ga_buff.result_pop, 
                     :time_to_run => (end_time - beginning_time) 
                   }
      job.status = 1
      job.save
    end
  rescue => error
    sleep 0.5
    puts "Waring occured"
    puts error.inspect
    retry
  end
end
# end backjobber