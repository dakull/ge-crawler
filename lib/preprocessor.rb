require 'open-uri'
require 'nokogiri'
#require 'loofah'
require 'uriio'
require 'chromosome'
require 'scanner'

class Preprocessor
  
  include UriIO
  
  def initialize( search_item = "monad", iteration = 1 )
    
    @scanners = []
    
    # scanners start
    buff = Scanner.new
    buff.search_items = search_item
    buff.uri_address = "http://google.com/search?q="
    buff.page_algorithm = Proc.new do |context|
      "&start=#{context.iteration*10}"
    end
    buff.selector = "h3.r > a.l"
    buff.iteration = iteration
    @scanners << buff
    
    buff = Scanner.new
    buff.search_items = search_item
    buff.uri_address = "http://www.bing.com/search?q="
    buff.page_algorithm = Proc.new do |context|
      "&first=#{context.iteration*10+1}"
    end
    buff.selector = "h3 > a"
    buff.iteration = iteration
    @scanners << buff
    # scanners end
    
    @search_item = search_item
  end
  
  def start_preprocessor
    # dc exista deja in queue
    # fix that error
    # ActiveRecord::Base.connection.reconnect!
    # if Job.where('name = ? AND status = ?', $search_item, 1).exists? then
    #   return -1
    # end
          
    # preia din scanners
    links_to_scan = []
    
    @scanners.each do |scanner|
      doc = get_uri(scanner.get_results)
      doc.css(scanner.selector).each do |link|
        links_to_scan << link['href']
      end
    end

    # fara duplicate
    links_to_scan.uniq!
      
    # threads = []
    results = []
    
    links_to_scan.each_with_index do |link,index|
    page_quality = 0
    unless link.include? 'https'
      #threads << Thread.new do
        puts "|--> " + link
        doc_child = get_uri(link)
        
        unless doc_child == nil
          related_links = doc_child.xpath('//a[contains(text(), "'+@search_item+'")]')
            puts "  --> nr linkuri : " + related_links.count.to_s
            
            related_links.css('a').each do |inner_link|
              puts "   --> " + inner_link.content
              buff = get_uri(link)
              no_of_occurences = buff.xpath('count(//*[contains(text(), "'+@search_item+'")])').to_i
              puts "   --> NO of app : " + no_of_occurences.to_s
              page_quality = page_quality + no_of_occurences
            end
            puts "   --> ** Page Quality : " + page_quality.to_s
            
            # creeaza cromozomul
            c = Chromosome.new
            c.uri = link
            c.page_quality = page_quality
            c.content = doc_child
            c.relevant_links = related_links
            c.links = doc_child.xpath('count(//a)')
            results << c
          end
        #end
      end
    end
    
    results.sort! do |a,b|
      a.page_quality <=> b.page_quality
    end
    
    #results.each do |res|
    #  puts "#{res.page_quality} | LINK: #{res.uri}"
    #end
      
    # join
    # threads.each do |thread|
    #   thread.join
    # end
    
    # jobul este gata save the data
    # jobul a inceput
    # job = Job.find_by_name(@search_item)      
    # ATENTIE !
    # job.status = 1
    # job.result = results
    # job.save
    
    results
  end
end

# end class