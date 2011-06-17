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

# start
beginning_time = Time.now

  jobs = Database::Job.find_all_by_status(0)
  jobs.each do |job,index|
    ga_buff = GeneticAlgorithm.new job.name, 4, &ge_mark_i
    ga_buff.probability_of_crossover = 0.5
    ga_buff.probability_of_mutation = 0.2
    ga_buff.run_algorithm
    
    job.result = [ga_buff.result, ga_buff.result_pop].to_json
    job.save
  end
  
end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)} sec"
