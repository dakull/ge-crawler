require 'preprocessor'

class GeneticAlgorithm
  
  attr_accessor :search_terms, :iterations, :algorithm, :result_pop, :result, :current_pop, :prev_pop, :probability_of_crossover, :probability_of_mutation
  
  def initialize(search_terms,iterations,&algorithm)
    @result = []
    @result_pop = []
    @search_terms = search_terms
    @iterations = iterations
    @algorithm = algorithm
  end
  
  def run_algorithm
    @algorithm.call(self)
  end
  
end

# end GeneticAlgorithm  