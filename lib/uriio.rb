# catch errors in a smart-way
module OpenUriBroken; end
# SocketError Timeout::Error
[Errno::EINVAL, Errno::ECONNRESET,EOFError, Errno::ETIMEDOUT, Errno::ECONNREFUSED,OpenURI::HTTPError ].each {|m| m.send(:include, OpenUriBroken) }

module UriIO
  
  def get_uri(uri_link)
    begin
      Nokogiri::HTML(open(uri_link))
    rescue OpenUriBroken, TypeError => e
      nil  
    end
  end
  
end