#
# Clasa pentru links stuff
# si procesarea acestora
#
require 'open-uri'
require 'nokogiri'

class Preprocessor
  
  attr_accessor :uri_address, :search_item 
  
  def initialize( search_item = "monad" )
    @uri_address = "http://google.com/search?q="
    @search_item = search_item
  end
  
  def start_preprocessor
    # foloseste nokogiri
    doc = Nokogiri::HTML(open(@uri_address+@search_item))
    # afiseaza titlul rezultatelor si href-urile ce vor fi procesate cu threaduri
    links_to_scan = []
    doc.css('h3.r > a.l').each do |link|
      links_to_scan << link['href']
    end
    
    # creaza threadurile si face mici prelucrari per fiecare link
    threads = []
    links_to_scan.each_with_index do |link,index|
      unless link.include? 'https'
        threads << Thread.new do 
          doc_child = Nokogiri::HTML(open(link))
          File.open("data_#{index}_#{@search_item}.txt", 'w') do |f|
            doc_child.css('h1').each do |node|
              f.write("Thread #{index}\n" )
              f.write(node.text + " \n" )
            end
          end
        end
      end
    end 
    
    # join
    threads.each do |thread| 
      thread.join
    end
  end
  
end
# end class