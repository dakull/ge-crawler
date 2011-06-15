require 'rubygems'
require 'active_record'

module Database

  ActiveRecord::Base.establish_connection(
    #:adapter => "jdbcmysql",
    :adapter => "mysql2",
    :host => "localhost",
    :database => "control",
    :username => "root",
    :password => ""
  )

end