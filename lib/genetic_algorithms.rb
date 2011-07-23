# CONTEXT :search_terms, :iterations, :algorithm, 
#         :result, :current_pop, :prev_pop, 
#         :probability_of_crossover
#
# GE_MARK_I
# 
def ge_mark_i
  lambda do |context|
    for i in 1..context.iterations do
      context.job.reload
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
          puts "CROSSOVER: #{rand} #{context.probability_of_crossover}"
          if rand < context.probability_of_crossover
            selected_offsprings << individual
          end
          # select and mutate
          puts "MUTATE: #{rand} #{context.probability_of_mutation}"
          if (rand < context.probability_of_mutation && individual.all_links != nil)
            puts "MUTATE: Making mutation in link"
            random_link = individual.all_links[rand(individual.all_links.length)]
            pm = PostrocessorMutation.new(random_link, context.search_terms)
            mutated_link = pm.gen_mutated_link
            unless mutated_link == nil
              population << mutated_link
            end
          end
        end
        
        # if odd remove one so we have an even number of parents
        unless selected_offsprings.count % 2 == 0
          selected_offsprings = selected_offsprings.drop 1
        end
        # limit no of offs to 20
        if selected_offsprings.count > 20 
          selected_offsprings = selected_offsprings.first 20
        end
        
        # offsprings are being made here   
        offspring, prev_individual, buff  = nil, nil, 0
        puts "NO of selected OFF: #{selected_offsprings.length}"
        selected_offsprings.each do |individual|
          buff += 1
          prev_individual = individual if buff == 1
          if buff == 2 
            pp = Postrocessor.new(prev_individual, individual, context.search_terms)
            offspring = pp.gen_offspring
            unless offspring == nil
              population << offspring
            end
            buff = 0
            prev_individual = nil
          end
        end
        # end crossover
        
        # prev_pop
        context.prev_pop = population
      end
              
      # uniq
      population = population.inject([]) do |hash,item|
        uniq = true
        hash.each { |hash_item| uniq = (hash_item.uri == item.uri) ? false : true ; break unless uniq }
        hash << item if uniq
        hash
      end
      
      # sort the array of individuals
      population.sort! do |a,b|
        a.page_quality <=> b.page_quality
      end
            
      # sort and limit at 10
      population = population.last 10
      population.each do |res|
        puts "| FPQ: #{res.page_quality} | LINK: #{res.uri}"
        context.result << { :pq => res.page_quality, :link => res.uri, :iteration => i }
      end
            
      puts "----------------------------------------------------------------------"
      puts "Population no #{i} Quality : #{(Float(population.first.page_quality + population.last.page_quality)/2)}"
      puts "----------------------------------------------------------------------"
      
      context.result_pop << { :pop_no => i, :pop_q => Float(population.first.page_quality + population.last.page_quality)/2 }
      
      # ISQ
      context.job.result = {
                     :links => context.result, 
                     :populations => context.result_pop
                   }
      context.job.save
      # break job
      if context.job.status != 2 
        break
      end
    end # for
  end 
end


# CONTEXT :search_terms, :iterations, :algorithm, 
#         :result, :current_pop, :prev_pop, 
#         :probability_of_crossover
#
# GE_MARK_II
# 
def ge_mark_ii
  lambda do |context|
    for i in 1..context.iterations do
      context.job.reload
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
          puts "CROSSOVER: #{rand} #{context.probability_of_crossover}"
          if rand < context.probability_of_crossover
            selected_offsprings << individual
          end
          # select and mutate
          puts "MUTATE: #{rand} #{context.probability_of_mutation}"
          if (rand < context.probability_of_mutation && individual.all_links != nil)
            puts "MUTATE: Making mutation in link"
            random_link = individual.all_links[rand(individual.all_links.length)]
            pm = PostrocessorMutation.new(random_link, context.search_terms)
            mutated_link = pm.gen_mutated_link
            unless mutated_link == nil
              population << mutated_link
            end
          end
        end
        
        # if odd remove one so we have an even number of parents
        unless selected_offsprings.count % 2 == 0
          selected_offsprings = selected_offsprings.drop 1
        end
        # limit no of offs to 20
        if selected_offsprings.count > 20 
          selected_offsprings = selected_offsprings.first 20
        end
        
        # offsprings are being made here   
        offspring, prev_individual, buff  = nil, nil, 0
        puts "NO of selected OFF: #{selected_offsprings.length}"
        selected_offsprings.each do |individual|
          buff += 1
          prev_individual = individual if buff == 1
          if buff == 2 
            pp = Postrocessor.new(prev_individual, individual, context.search_terms)
            offspring = pp.gen_offspring
            unless offspring == nil
              population << offspring
            end
            buff = 0
            prev_individual = nil
          end
        end
        # end crossover
        
        # prev_pop
        context.prev_pop = population
      end
              
      # uniq
      population = population.inject([]) do |hash,item|
        uniq = true
        hash.each { |hash_item| uniq = (hash_item.uri == item.uri) ? false : true ; break unless uniq }
        hash << item if uniq
        hash
      end
      
      # sort the array of individuals
      population.sort! do |a,b|
        a.page_quality <=> b.page_quality
      end
            
      # random select based on page quality
      post_population = []
      population.each do |res|
        pgi = rand(res.page_quality)
        post_population << res if pgi < res.page_quality
        puts "Weighted RANDOM #{pgi} #{res.page_quality}"
      end
      
      # check if pop size > 0
      if post_population.length > 0 
        # Weighted RANDOM Pop becomes new population
        population = post_population  
      end
      
      # sort and limit at 10
      population = population.last 10 if population.length > 10
      population.each do |res|
        puts "| FPQ: #{res.page_quality} | LINK: #{res.uri}"
        context.result << { :pq => res.page_quality, :link => res.uri, :iteration => i }
      end
            
      puts "----------------------------------------------------------------------"
      puts "Population no #{i} Quality : #{(Float(population.first.page_quality + population.last.page_quality)/2)}"
      puts "----------------------------------------------------------------------"
      
      context.result_pop << { :pop_no => i, :pop_q => Float(population.first.page_quality + population.last.page_quality)/2 }
      
      # ISQ
      context.job.result = {
                     :links => context.result, 
                     :populations => context.result_pop
                   }
      context.job.save
      # break job
      if context.job.status != 2 
        break
      end
    end # for
  end 
end