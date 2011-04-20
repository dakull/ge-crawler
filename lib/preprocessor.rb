#
# Clasa pentru links stuff
# si procesarea acestora
#
require 'open-uri'
require 'nokogiri'

class Preprocessor
  
  attr_accessor :uri_address, :search_item, :results 
  
  def initialize( search_item = "monad" )
    @uri_address = "http://google.com/search?q="
    @search_item = search_item
    # start
    start_preprocessor
  end
  
  private
  
    def start_preprocessor
      # dc exista dja in queue
      ActiveRecord::Base.connection.reconnect!
      if Job.where('name = ? AND status = ?', $search_item, 1).exists? then
        return -1
      end
      
      # jobul a inceput
      job = Job.find_by_name(@search_item)
      
      # foloseste nokogiri
      doc = Nokogiri::HTML(open(@uri_address+@search_item))
      # afiseaza titlul rezultatelor si href-urile ce vor fi procesate cu threaduri
      links_to_scan = []
      doc.css('h3.r > a.l').each do |link|
        links_to_scan << link['href']
      end
      
      # creaza threadurile si face mici prelucrari per fiecare link
      threads = []
      results = []
      links_to_scan.each_with_index do |link,index|
        unless link.include? 'https'
          threads << Thread.new do 
            doc_child = Nokogiri::HTML(open(link))
              doc_child.css('h1').each do |node|
                #results << { "Thread #{index}" => node.text }
                results[index] = node.text
              end
          end
        end
      end 
      
      # join
      threads.each do |thread|
        thread.join
      end
      
      # jobul este gata
      job.status = 1
      job.result = results
      job.save
    end
  
end

# end class