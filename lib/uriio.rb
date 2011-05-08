%w(open-uri timeout socket).each { |d| require d }
# catch errors in a smart-way
module OpenUriBroken; end
# SocketError Timeout::Error
[SocketError,Timeout::Error,Errno::EINVAL, Errno::ECONNRESET,EOFError, Errno::ETIMEDOUT, Errno::ECONNREFUSED,OpenURI::HTTPError,Errno::ENOENT ].each {|m| m.send(:include, OpenUriBroken) }

module UriIO
  
  require 'uri'
  
  def get_uri(uri_link)
    begin
      Nokogiri::HTML(open(uri_link))
    rescue OpenUriBroken, TypeError => e
      nil  
    end
  end
  
  def make_absolute( href, root )
    uri = URI.parse(href)
    uri = URI.parse(root).merge(href) if uri.relative?
    uri.to_s
  end
  
end