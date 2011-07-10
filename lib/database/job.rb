module Database

  class Job < ActiveRecord::Base
    serialize :settings
    serialize :result
      
    before_save do
      self.status = 0 unless self.status
      # elimina cuvintele din array - /i case insensitive - \b word boundary \b
      %w[the of to and a in is it].each { |word| self.name = name.gsub(/\b#{word}\b/i, '').gsub(/[ ]{2,}/,' ').downcase.strip } if self.name
    end
    
    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false
    validates_numericality_of :crossover_p, :mutation_p, :algo, :iterations
      
    def self.serialized_attr_accessor(*args)
      args.each do |method_name|
        method_declarations = <<-TOEVAL
          def #{method_name}
            self.settings = Hash.new unless self.settings
            self.settings.fetch(:#{method_name},0)
          end
          def #{method_name}=(value)
            self.settings = Hash.new unless self.settings
            self.settings[:#{method_name}] = value
          end
        TOEVAL
        eval method_declarations
      end
    end
    
    serialized_attr_accessor :iterations, :crossover_p, :mutation_p, :algo
   
  end

end