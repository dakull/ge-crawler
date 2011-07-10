require 'uri'

class Scanner
  
  attr_accessor :uri_address, :page_algorithm, :selector, :search_items, :iteration
  
  def initialize( iteration = 1 )
    @iteration = iteration
  end
  
  def get_results
    if @iteration == 1 
      URI.escape(@uri_address.to_s + @search_items.to_s)
    elsif @iteration > 1
      paging_code = @page_algorithm.call(self)
      URI.escape(@uri_address.to_s + @search_items.to_s + paging_code)
    end
  end
  
end