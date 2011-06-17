population = []

class Chromosome
  
  attr_accessor :uri, :page_quality, :content, :relevant_links, :links, :all_links
  
end


population << b = Chromosome.new; b.uri = "ceva"
population << b = Chromosome.new; b.uri = "ceva1"
population << b = Chromosome.new; b.uri = "ceva"
population << b = Chromosome.new; b.uri = "ceva2"
population << b = Chromosome.new; b.uri = "ceva3"
population << b = Chromosome.new; b.uri = "ceva4"

# uniq
population = population.inject([]) do |hash,item|
  uniq = true
  hash.each { |hash_item| uniq = (hash_item.uri == item.uri) ? false : true ; break unless uniq }
  puts uniq.inspect
  hash << item if uniq
  hash
end

population.each do |res|
  puts "| FPQ: | LINK: #{res.uri}"
end
