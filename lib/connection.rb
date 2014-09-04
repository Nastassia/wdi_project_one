require 'active_record'

ActiveRecord::Base.establish_connection({
  :adapter => "postgresql",
  :host => "localhost",
  :username => "medusa",
  :database => "ivalice"
  })

  ActiveRecord::Base.logger = Logger.new(STDOUT)
