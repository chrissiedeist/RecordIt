require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    p "The model class is #{self.class_name.to_s.constantize}"
    self.class_name.to_s.constantize
  end

  def table_name
    return "humans" if self.class_name == "Human"
    p "The class name is #{self.class_name.downcase.to_s}s"
    "#{self.class_name.downcase.to_s}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    #Cat                       
    #belongs_to(          
    # :human,                     < - name
    # :class_name => :Human,       < - options
    # :foreign_key => :owner_id,
    # :primary_key => :id
    @name = name
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
    # ...
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    #Human                       < - self_class_name
    #has_many(          
    # :cats,                     < - name
    # :class_name => :Cat,       < - options
    # :foreign_key => :owner_id,
    # :primary_key => :id
    @name = name
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.to_s.camelcase.singularize
    
    puts "I am the options hash and my foreign key is #{@foreign_key}"
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    
    #options.name = human
      #options.foreign_key = :owner_id
      #option.primary_key = :id
      #options.class_name = "Human"
      #options.table_name = "humans"
      #options.model_class = Human
    define_method(name) do
      foreign_key = self.send(options.foreign_key)

      #Human.where(:id => self.owner_id)
      results = options.model_class.where(options.primary_key => foreign_key)
      @association_options[name] = results.first
      results.first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)

    define_method(name) do  
    #options.name = cats
      #options.foreign_key = :owner_id
      #option.primary_key = :id
      #options.class_name = "Cat"
      #options.table_name = "cats"
      #options.model_class = Cat
      #
      #Cat.where(:owner_id => self.id)

      foreign_key = options.foreign_key
      primary_key = options.primary_key
      options.model_class.where(foreign_key => self.send(primary_key))
    end
  end

  def assoc_options
    @assoc_options ||= Hash.new
  end

  def has_one_through(name, through_name, source_name)
    through_options = self.class.assoc_options[through_name]
    # Cat has one though :home, :human, :house
    #
    #Cat                       
    #belongs_to(          
    # :human,                     < - name
    # :class_name => :Human,       < - options
    # :foreign_key => :owner_id,
    # :primary_key => :id
    #
    # Cat belongs to human
    #through_options.name = human
      #through_options.foreign_key = :owner_id
      #through_options.primary_key = :id
      #through_options.class_name = "Human"
      #through_options.table_name = "humans"
      #through_options.model_class = Human
    
    #
    # Human belongs to house
    #options.name = home
      #source_options.foreign_key = :house_id
      #source_options.primary_key = :id
      #source_options.class_name = "House"
      #source_options.table_name = "houses"
      #source_options.model_class = House
      #

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]
    end
    
      source_table = source_options.table_name
      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key

      through_table = through_options.table_name
      through_pk = through_options.primary_key

      key_val = self.send(through_options.foreign_key)
      
    through_table =   
    query = <<-SQL
      SELECT
        #{source_table}.*
      FROM
        #{source_table}
      JOIN
        #{through_table}
        ON #{source_table}.#{source_pk} = #{through_table}.#{source_fk}
      WHERE 
        #{through_table}.#{through_pk} = ?

        SQL
    # query = <<-SQL
    # SELECT 
    #   houses.*
    # 
    # FROM 
    #   houses 
    # JOIN
    #   humans
    #   ON houses.id = humans.house_id
    # WHERE
    #   humans.id = self.owner_id

    results = DBConnection.execute(query, key_val)
    self.parse_all(results)
  end
end

class SQLObject
  extend Associatable
end
