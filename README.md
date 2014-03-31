#ActiveRecordLite

##A recreation of ActiveRecord's key features and functionality

Defines a class SQLObject with the following class and instance methods:

Class methods:
 + all
 + find

Instance methods:
 + insert
 + save
 + update
 
For example, if you have a table "Cats" in your database, you could create Cat.rb:
   
   class Cat < SQLObject
   end
   
   cat = Cat.find(1)
   puts "#{cat.name} belongs to user ##{cat.owner_id}"
   
   ajax = Cat.new(:name => "Ajax", :owner_id => 123)
   ajax.insert

Also defines the following modules:
 + Searchable (adding the class method "where")
 + Associatable (allowing for the methods has_many, belongs_to, and has_many_through
 




