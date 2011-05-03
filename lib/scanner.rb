class Scanner
  
  attr_accessor :uri_address, :page, :selector, :search_items
  
  def first_search
    @uri_address.to_s + @search_items.to_s
  end
  
end