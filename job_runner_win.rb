# TODO: abstract si ppt 
# 70 pg
# 28 mai conf. ses. de com.

$LOAD_PATH << './lib'
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

  jobs = Job.find_all_by_status(0)
  jobs.each do |job,index|
    ga_buff = GeneticAlgorithm.new job.name, 2, &ge_mark_i
    ga_buff.probability_of_crossover = 0.7
    ga_buff.probability_of_mutation = 0.9
    ga_buff.run_algorithm
    
    job.result = [ga_buff.result, ga_buff.result_pop].to_json
    job.save
  end
  
end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)} sec"

# trimis mail - leahu - ppt
# mutatie - selectez un link care nu contine keywords
# http://math.univ-ovidius.ro/Doc/Admitere/SesiuneInfo/2011/SesComInf2011.pdf