require 'uri'
require 'customlogger'

module UriIO
  
  include CustomLogger
  
  def get_uri(uri_link)
    begin
      Nokogiri::HTML(open(uri_link))
    rescue Exception => error
      log_exception
      nil
    end
  end
  
  def make_absolute( href, root )
    uri = URI.parse(href)
    uri = URI.parse(root).merge(href) if uri.relative?
    uri.to_s
  end
  
  def get_uri_host( the_uri )
    uri = URI.parse(the_uri)
    uri.host
  end
  
end