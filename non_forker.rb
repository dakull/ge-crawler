#
# Cu 1 proces prin fork
# dependente: preprocessor.rb
#
require 'open-uri'
require 'nokogiri'
require './preprocessor.rb'

beginning_time = Time.now

  prep = Preprocessor.new "ruby"
  prep.start_preprocessor
  prep2 = Preprocessor.new "javascript"
  prep2.start_preprocessor

end_time = Time.now
puts "Timpul rularii #{(end_time - beginning_time)*1000} milliseconds"
