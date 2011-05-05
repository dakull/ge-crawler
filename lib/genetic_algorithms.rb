# :search_terms, :iterations, :algorithm, :result, :current_pop, :prev_pop, :probability_of_crossover
# Prima varianta de algoritm : 

def ge_mark_i
  lambda do |context|
    for i in 1..context.iterations do
      # heuristic creation 
      prep = Preprocessor.new context.search_terms, i
      population = prep.start_preprocessor
           
      if i == 1 
        population = population.last 5
        context.prev_pop = population
      else
        # selection
        population = context.prev_pop | population
        
        # crossover ?
        offspring = nil
        if rand < context.probability_of_crossover
          parents = population.first 2          
          offspring = Postrocessor.new parents[0], parents[1], context.search_terms
        end
        unless offspring == nil
          population << offspring
        end
        # end crossover
        
        # sort
        population.sort! do |a,b|
          a.page_quality <=> b.page_quality
        end        
        
        context.prev_pop = population
      end
      
      population.each do |res|
        puts "#{res.page_quality} | LINK: #{res.uri}"
      end
      
      puts "Population no #{i} Quality : #{(population.first.page_quality + population.last.page_quality)/2}"
    end
  end
end