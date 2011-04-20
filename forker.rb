#
# Cu 2 procese prin fork
# dependente: preprocessor.rb
#
require 'open-uri'
require 'nokogiri'
require './preprocessor.rb'

beginning_time = Time.now

  # proces unu
  # codul din block ruleaza intr-un nou proces
  pid_proces_unu = Process.fork do 
      prep = Preprocessor.new "ruby"
      prep.start_preprocessor
  end
  puts "## Fork Process 1 PID: " + pid_proces_unu.to_s
  
  # proces doi
  pid_proces_doi = Process.fork do 
      prep = Preprocessor.new "javascript"
      prep.start_preprocessor
  end
  puts "## Fork Process 2 PID: " + pid_proces_doi.to_s
  
  # wait to finish
  Process.wait

end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)*1000} milisecunde"

# exit status
puts "Exit " + $?.exitstatus.to_s