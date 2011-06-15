module CustomLogger
  
  def log_exception( show_gem_list = false, show_backtrace = false ) 
    open('crash.log', 'a') do |log|
      error = {
                :timestamp  =>  Time.now,
                :message      =>  $!.message,
                :backtrace  =>  show_backtrace ? $!.backtrace : 'specify show_backtrace = true attr please',
                :gems => show_gem_list ? Gem.loaded_specs.inject({}) {|m,  (n,s)|  m.merge(n  =>  s.version)} : 'specify show_gem_list = true attr please'
              }
      YAML.dump(error,  log)      
    end
  end
  
end
