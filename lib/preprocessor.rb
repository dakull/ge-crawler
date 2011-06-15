require 'open-uri'
require 'nokogiri'
require 'chromosome'
require 'scanner'
require 'uriio'
require 'customlogger'

class Preprocessor
  
  include UriIO
  include CustomLogger
  
  def initialize( search_item = "none", iteration = 1, pop_size = 10 )
    @pop_size = pop_size    
    @search_item = search_item
    @iteration = iteration
    self.gen_scanners
  end
  
  def start_preprocessor

    # preia din scanners
    links_to_scan = []
    
    @scanners.each do |scanner|
      puts "*** SEARCH URI: #{scanner.get_results}"
      doc = get_uri(scanner.get_results)
      doc.css(scanner.selector).each do |link|
        links_to_scan << link['href']
      end
    end

    # fara duplicate
    links_to_scan.uniq!
    
    # for keeping the pop_size
    # links_to_scan = links_to_scan.first @pop_size
      
    threads = []
    results = []
    
    links_to_scan.each_with_index do |link,index|      
      page_quality = 0
      threads << Thread.new do
        begin
          assert(get_uri(link))
          doc_child = get_uri(link)
          link_host = get_uri_host link
          related_links = doc_child.xpath('//a[contains(text(), "'+@search_item+'")]')
          
          related_links.each do |inner_link|
            begin
              inner_link_href = inner_link['href']
              assert(get_uri(inner_link_href))
              related_links_page = get_uri(inner_link_href)            
              no_of_occurences = inner_link_href.include?(link_host) ? 1 : related_links_page.xpath('count(//*[contains(text(), "'+@search_item+'")])').to_i
              page_quality = page_quality + no_of_occurences
            rescue Exception => error
              log_exception false, true
            end
          end
          
        rescue Exception => error
          log_exception false, true
        else
          c = Chromosome.new
          c.uri = link
          c.page_quality = page_quality
          c.content = doc_child
          c.relevant_links = related_links
          c.links = doc_child.xpath('count(//a)')
          c.all_links = doc_child.xpath('//a')
          results << c
        end
      end
    end
    
    results.sort! do |a,b|
      a.page_quality <=> b.page_quality
    end
          
    # threads join
    threads.each do |thread|
      thread.join
    end
    
    # some info
    results.each do |res|
      puts "#{res.page_quality} | LINK: #{res.uri}"
    end
    
    results
    
    # dc exista deja in queue
    # fix that error
    # ActiveRecord::Base.connection.reconnect!
    # if Job.where('name = ? AND status = ?', $search_item, 1).exists? then
    #   return -1
    # end
        
    # jobul este gata save the data
    # jobul a inceput
    # job = Job.find_by_name(@search_item)      
    # ATENTIE !
    # job.status = 1
    # job.result = results
    # job.save
  end
  
  def assert(value, message="Assertion failed")
    raise Exception, message, caller unless value
  end
  
  def gen_scanners
    @scanners = []
    buff = Scanner.new
    buff.search_items = @search_item
    buff.uri_address = "http://google.com/search?q="
    buff.page_algorithm = Proc.new do |context|
      "&start=#{context.iteration*@pop_size}"
    end
    buff.selector = "h3.r > a.l"
    buff.iteration = @iteration
    @scanners << buff
    
    buff = Scanner.new
    buff.search_items = @search_item
    buff.uri_address = "http://www.bing.com/search?q="
    buff.page_algorithm = Proc.new do |context|
      "&first=#{context.iteration*@pop_size+1}"
    end
    buff.selector = "h3 > a"
    buff.iteration = @iteration
    @scanners << buff
  end

end # end class