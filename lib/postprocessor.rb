require 'open-uri'
require 'nokogiri'
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
    rel_links_no << @first_parent.relevant_links.count
    rel_links_no << @second_parent.relevant_links.count
    rel_links_no.sort!
    
    unless rel_links_no.first == 0 && rel_links_no.last == 0
      
      #not_permitted = [nil,'https','mailto','ftp']
      
      # abs links
      le_links_first_parent = []
      @first_parent.relevant_links.each do |node|
        unless node['href'] == nil || node['href'].include?('https') || node['href'].include?('mailto') || node['href'].include?('ftp')
          le_links_first_parent << make_absolute(node['href'], @first_parent.uri)
        end
      end
      
      # abs links
      le_links_second_parent = []
      @second_parent.relevant_links.each do |node|
        unless node['href'] == nil || node['href'].include?('https') || node['href'].include?('mailto') || node['href'].include?('ftp')
          le_links_second_parent << make_absolute(node['href'], @second_parent.uri)
        end
      end
      
      min_count = [le_links_first_parent.count, le_links_second_parent.count].min
      if min_count == 0
        return nil
      elsif min_count == 1
        cut_point = 1
      else
        cut_point = rand( min_count )  
      end
      
      puts "cutpoint: #{cut_point}"
      puts "le_links_first_parent #{le_links_first_parent.count}"
      puts "le_links_second_parent #{le_links_second_parent.count}"
      #combined_links =  le_links_first_parent[0,cut_point-1] |
      #                  le_links_second_parent[cut_point-1,le_links_second_parent.count-1]
      combined_links = le_links_first_parent | le_links_second_parent
      
      link_uri = nil
      #times = 0
      #while times < combined_links.count || link_uri == nil || link_uri.include?('https') || link_uri.include?('mailto')
      #  link_uri = combined_links[rand(combined_links.count)-1]
      #  times += 1
      #end
      
      #for i in 1..combined_links.count
      #  if times < combined_links.count || link_uri == nil || link_uri.include?('https') || link_uri.include?('mailto')
      #    link_uri = combined_links[rand(combined_links.count)-1]
      #  end
      #end
      
      link_uri = combined_links[rand(combined_links.count-1)]
      
      #start to generate offspring
      page_quality = 0
      doc_child = get_uri(link_uri)
      unless doc_child == nil
        puts "|--> Offspring link : " + link_uri
        
        relevant_links = doc_child.xpath('//a[contains(text(), "'+@search_item+'")]')
          puts "  --> Offspring nr linkuri : " + relevant_links.count.to_s
          
          relevant_links.css('a').each do |inner_link|
            puts "   --> Offspring " + inner_link.content
            buff = get_uri(inner_link)
            unless buff == nil
              no_of_occurences = buff.xpath('count(//*[contains(text(), "'+@search_item+'")])').to_i
              puts "   --> Offspring NO of app : " + no_of_occurences.to_s
              page_quality = page_quality + no_of_occurences
            end
          end
          
          puts "   --> ** Offspring Page Quality : " + page_quality.to_s
          
          offspring = Chromosome.new
          offspring.uri = link_uri
          offspring.page_quality = page_quality
          #offspring.content = doc_child
          offspring.relevant_links = relevant_links
          offspring.links = doc_child.xpath('count(//a)')
      end
    end
    
    offspring
  end
  
end