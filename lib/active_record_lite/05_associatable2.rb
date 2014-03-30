require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  define_method(name) do
    source_options = through_options.model_class.assoc_options[source_name]
  end
  
    source_table = source_options.table_name
    source_pk = source_options.primary_key
    source_fk = source_options.foreign_key

    through_table = through_options.table_name
    through_pk = through_options.primary_key

    key_val = self.send(through_options.foreign_key)

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
