#
# Clasa pentru links stuff
# si procesarea acestora
#
require 'open-uri'
require 'nokogiri'
require 'loofah'
require 'uriio'

class Preprocessor
  
  include UriIO
  
  attr_accessor :uri_address, :search_item, :results 
  
  def initialize( search_item = "monad" )
    @uri_address = "http://google.com/search?q="
    @search_item = search_item
    # start
    start_preprocessor
  end
  
  private
  
    def start_preprocessor
      # dc exista deja in queue
      # fix that error
      ActiveRecord::Base.connection.reconnect!
      if Job.where('name = ? AND status = ?', $search_item, 1).exists? then
        return -1
      end
      
      # jobul a inceput
      job = Job.find_by_name(@search_item)
      
      doc = get_uri(@uri_address+@search_item)
      # preia primele pagini
      links_to_scan = []
      doc.css('h3.r > a.l').each do |link|
        links_to_scan << link['href']
      end
      
      # threads = []
      results = []
      
      links_to_scan.each_with_index do |link,index|
        page_quality = 0
        unless link.include? 'https'
          #threads << Thread.new do
            puts "|--> " + link
            doc_child = get_uri(link)
          
            related_links = doc_child.xpath('//a[contains(text(), "'+@search_item+'")]')
            puts "  --> nr linkuri : " + related_links.count.to_s
            
            related_links.css('a').each do |inner_link|
              puts "   --> " + inner_link.content
              buff = get_uri(link)
              no_of_occurences = buff.xpath('count(//*[contains(text(), "'+@search_item+'")])').to_i
              puts "   --> NR de Aparente : " + no_of_occurences.to_s
              page_quality = page_quality + no_of_occurences
            end
            puts "   --> ** Page Quality : " + page_quality.to_s
          #end
        end
      end
      
      # join
      # threads.each do |thread|
      #   thread.join
      # end
      
      # jobul este gata save the data
      # ATENTIE !
      # job.status = 1
      job.result = results
      job.save
    end
  
end

# end class