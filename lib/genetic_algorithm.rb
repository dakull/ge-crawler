require 'preprocessor'

class GeneticAlgorithm
  
  attr_accessor :search_terms, :iterations, :algorithm, :result, :current_pop, :prev_pop, :probability_of_crossover
  
  def initialize(search_terms,iterations,&algorithm)
    @search_terms = search_terms
    @iterations = iterations
    @algorithm = algorithm
  end
  
  def run_algorithm
    @algorithm.call(self)
  end
  
end

# end GeneticAlgorithm  