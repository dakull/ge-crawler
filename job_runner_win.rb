$LOAD_PATH << './lib'
require 'database_configuration.rb'
require 'job.rb'
require 'genetic_algorithm.rb'
require 'genetic_algorithms.rb'
require 'preprocessor.rb'
require 'postprocessor.rb'

# start
beginning_time = Time.now

  jobs = Job.find_all_by_status(0)
  jobs.each do |job,index|
    ga_buff = GeneticAlgorithm.new job.name, 10, &ge_mark_i
    ga_buff.probability_of_crossover = 0.7
    ga_buff.run_algorithm
  end
  
end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)} sec"

# trimis mail - leahu - ppt
# mutatie - selectez un link care nu contine keywords
# http://math.univ-ovidius.ro/Doc/Admitere/SesiuneInfo/2011/SesComInf2011.pdf