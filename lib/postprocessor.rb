require 'open-uri'
require 'nokogiri'
#require 'loofah'
require 'uriio'
require 'chromosome'
require 'scanner'

class Postrocessor
  
  attr_accessor :first_parent, :second_parent, :search_item
  
  include UriIO
  
  def initialize(first_parent,second_parent,search_item)
    @first_parent = first_parent
    @second_parent = second_parent
    @search_item = search_item
  end
  
  def gen_offspring
    offspring = nil
    rel_links_no = []
    rel_links_no << @first_parent.related_links.count
    rel_links_no << @second_parent.related_links.count
    rel_links_no.sort!
    unless rel_links_no.first == 0 || rel_links_no.last == 0
      cut_point = rand(rel_links_no.first)
      combined_links =  @first_parent.related_links.first(cut_points) | @second_parent.related_links.last(cut_points) 
      offspring = combined_links[rand(combined_links.count)-1]
      
      #start
      doc_child = get_uri(offspring.uri)
      unless doc_child == nil
        related_links = doc_child.xpath('//a[contains(text(), "'+@search_item+'")]')
          puts "  --> Offspring nr linkuri : " + related_links.count.to_s
          
          related_links.css('a').each do |inner_link|
            puts "   --> Offspring " + inner_link.content
            buff = get_uri(link)
            no_of_occurences = buff.xpath('count(//*[contains(text(), "'+@search_item+'")])').to_i
            puts "   --> Offspring NO of app : " + no_of_occurences.to_s
            page_quality = page_quality + no_of_occurences
          end
          puts "   --> ** Offspring Page Quality : " + page_quality.to_s
          
          offspring.page_quality = page_quality
          offspring.content = doc_child
          offspring.relevant_links = related_links
          offspring.links = doc_child.xpath('count(//a)')
      end   
      # end   
    end
    
    offspring
  end
  
end