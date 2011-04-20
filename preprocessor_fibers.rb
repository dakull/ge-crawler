#
# Clasa pentru links stuff
# si procesarea acestora
# with fibers now
#
require 'open-uri'
require 'nokogiri'
require 'fiber'

class Preprocessor
  
  attr_accessor :uri_address, :search_item, :fibers
  
  def initialize( search_item = "monad" )
    @uri_address = "http://google.com/search?q="
    @search_item = search_item
    @fibers = []
  end
  
  def http_get(link,index)
    # open link callback for fiber
    html_result = nil
    html_size = nil
    html_result = open(link,
      :content_length_proc => lambda {|t|
        if t && 0 < t
          html_size = t
        end
      },
      :progress_proc => lambda {|s|
        @fibers[index].resume(html_result) if s == html_size
      }
    )
    
    return @fibers.yield
  end
  
  def start_preprocessor
    # foloseste nokogiri
    doc = Nokogiri::HTML(open(@uri_address+@search_item))
    links_to_scan = []
    doc.css('h3.r > a.l').each do |link|
      links_to_scan << link['href']
    end
    
    # creaza fibrele si face mici prelucrari per fiecare link
    doc_child = nil
    fib = Fiber.new do
      links_to_scan.each_with_index do |link,index|
        unless link.include? 'https'  
          doc_child = Nokogiri::HTML(open(link))
          Fiber.yield
        end
      end
    end
    
    links_to_scan.size.times do
      File.open("data__#{@search_item}.txt", 'a') do |f|
        doc_child.css('h1').each do |node|
          f.write("Thread #{index}\n" )
          f.write(node.text + " \n" )
        end
      end
    
      fib.resume      
    end
    
    # resume
    #@fibers.each do |thread| 
    #  thread.resume
    #end
  end
  
end
# end class