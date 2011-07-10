require 'open-uri'
require 'nokogiri'
require 'uriio'
require 'chromosome'
require 'scanner'

class PostrocessorMutation
  
  attr_accessor :le_link
  
  include UriIO
  
  def initialize(le_link,search_item)
    @le_link = le_link
    @search_item = search_item
  end
  
  def gen_mutated_link
    offspring = nil
    begin   
      link_uri = le_link['href']
      #start to generate mutated link
      page_quality = 0
      doc_child = get_uri(link_uri)
      unless doc_child == nil
        puts "|--> Mutated link : " + link_uri
        
        relevant_links = doc_child.xpath('//a[contains(text(), "'+@search_item+'")]')
          puts "  --> Mutated nr linkuri : " + relevant_links.count.to_s
          
          relevant_links.css('a').each do |inner_link|
            puts "   --> Mutated " + inner_link.content
            buff = get_uri(inner_link)
            unless buff == nil
              no_of_occurences = buff.xpath('count(//*[contains(text(), "'+@search_item+'")])').to_i
              puts "   --> Mutated NO of app : " + no_of_occurences.to_s
              page_quality = page_quality + no_of_occurences
            end
          end
          
          puts "   --> ** Mutated Page Quality : " + page_quality.to_s
          
          offspring = Chromosome.new
          offspring.uri = link_uri
          offspring.page_quality = page_quality
          #offspring.content = doc_child
          offspring.relevant_links = relevant_links
          offspring.links = doc_child.xpath('count(//a)')
      end
    rescue Exception => error
      log_exception
    end
    offspring
  end
  
end