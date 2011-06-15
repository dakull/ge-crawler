# CONTEXT :search_terms, :iterations, :algorithm, :result, :current_pop, :prev_pop, :probability_of_crossover
# Algorithm 1st version GE_MARK_I : 
def ge_mark_i
  lambda do |context|
    for i in 1..context.iterations do
      # heuristic creation 
      prep = Preprocessor.new context.search_terms, i, 10
      population = prep.start_preprocessor      
           
      if i == 1 
        context.prev_pop = population
      else
        # selection
        population = context.prev_pop | population
        
        # crossover part start here
        # each individual can be selected for crossover
        # if the probability is high enough
        selected_offsprings = []
        population.each do |individual|
          # select for crossover
          if rand < context.probability_of_crossover
            selected_offsprings << individual
          end
          # select and mutate
          rand = 10 # remove this
          if rand < context.probability_of_mutation
            puts "Making mutation in link"
            random_link = individual.all_links[rand(individual.all_links.length)]
            mutated_link = PostrocessorMutation.new random_link
            unless offspring == nil
              population << mutated_link
            end
          end
        end
        
        # if odd remove one so we have an even number of parents
        unless selected_offsprings.count % 2 == 0
          selected_offsprings = selected_offsprings.drop 1
        end
        
        # offsprings are being made here   
        offspring, prev_individual, buff  = nil, nil, 0
        selected_offsprings.each do |individual|
          buff += 1
          prev_individual = individual
          if buff == 2 
            pp = Postrocessor.new(prev_individual, individual, context.search_terms)
            offspring = pp.gen_offspring
            unless offspring == nil
              population << offspring
            end
            buff = 0
            individual = nil
          end
        end
        # end crossover
        
        # sort the array of individuals
        population.sort! do |a,b|
          a.page_quality <=> b.page_quality
        end
        
        context.prev_pop = population.last 10
      end
      
      population = population.last 10
      population.each do |res|
        puts "#{res.page_quality} | LINK: #{res.uri}"
        context.result << { "pq" => res.page_quality, "link" => res.uri }
      end
      
      puts "----------------------------------------------------------------------"
      puts "Population no #{i} Quality : #{(population.first.page_quality + population.last.page_quality)/2}"
      puts "----------------------------------------------------------------------"
      
      context.result_pop << {"pop_no" => i, "pop_q" => (population.first.page_quality + population.last.page_quality)/2}
    end
  end
end