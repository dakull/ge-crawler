module GA

  class GeneticAlgorithm
    
    attr_accessor :search_terms, :iterations, :algorithm
    
    def initialize(iterations,algorithm)
      @iterations = iterations
      @algorithm = algorithm
    end
    
    def run_algorithm
      @algorithm.call(self)
    end
    
  end

  # testing grounds : 
  def test_run
    ge_mark_i = Proc.new { |context|
      for i in 1..context.iterations do
        puts i
      end
    }
    
    buff = GeneticAlgorithm.new 40, ge_mark_i
    buff.iterations = 40
    buff.run_algorithm
  end
  
end


class Test
  include GA
end

Test.new.test_run

# end module GA  