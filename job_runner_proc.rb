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

counter = 0
procs_current = []
no_of_running_procs = 0

# infinite loop
loop do
  # sleep for 500ms
  sleep 1
  #puts "In loop: #{(counter += 1).to_s} NO of procs: #{no_of_running_procs}"
  begin
    # reconnect
    # fork net. conn. are in an inconsistent state
    ActiveRecord::Base.connection.reconnect!
    jobs = Database::Job.find_all_by_status(0)
    jobs.each do |job,index|
      if no_of_running_procs <= 2
        no_of_running_procs += 1
        uid = job.id
        procs_current << Process.fork do |uid|
          # reconnect
          # fork net. conn. are in an inconsistent state
          ActiveRecord::Base.connection.reconnect!
          puts "Processing job: #{job.name} and no of procs #{no_of_running_procs}"
          # time to run
          beginning_time = Time.now
          # init algo
          # select algo
          if (job.settings[:algo] == 1)
            ga_buff = GeneticAlgorithm.new job.name, job.settings[:iterations], &ge_mark_i
          else
            ga_buff = GeneticAlgorithm.new job.name, job.settings[:iterations], &ge_mark_ii
          end
          # set basic stuff
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
        end # proc
      end # if
      # trap for end of process
      # CLD = Child Died Signal in Linux
      trap("CLD") {
        pid = procs_current.last
        no_of_running_procs -= 1
        puts "Child pid #{pid}: terminated no of procs #{no_of_running_procs}"
      }
    end # block

    # wait to finish
    # Process.wait(0)
  rescue => error
    sleep 0.5
    puts "Warning occured"
    puts error.inspect
    retry
  end
end
# end backjobber

