module Database

  class Job < ActiveRecord::Base
    serialize :result
  end

end