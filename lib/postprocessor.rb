require 'open-uri'
require 'nokogiri'
#require 'loofah'
require 'uriio'
require 'chromosome'
require 'scanner'

class Postrocessor
  
  attr_accessor :first_parent, :second_parent
  
  include UriIO
  
  def initialize(first_parent,second_parent)
    @first_parent = first_parent
    @second_parent = second_parent
  end
  
  def gen_offspring
    rel_links_no = []
    rel_links_no << @first_parent.related_links.count
    rel_links_no << @second_parent.related_links.count
    rel_links_no.sort!
    unless rel_links_no.first == 0 OR rel_links_no.last == 0
      rand(rel_links_no.first)
      
    end
  end
  
end