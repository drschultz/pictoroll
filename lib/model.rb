require 'sequel'

Sequel.sqlite("#{File.dirname(__FILE__)}/../pictoroll.db")

class Post < Sequel::Model
  
end

class Author < Sequel::Model
  
end