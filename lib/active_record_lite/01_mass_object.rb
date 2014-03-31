class MassObject
  def self.my_attr_accessible(*attributes)
		attributes.each do |attribute|
			define_method("#{attribute}=") do |value|
				instance_variable_set("@#{attribute}", value)
			end
			define_method(attribute) do
				instance_variable_get("@#{attribute}")
			end
		end

		@attributes = attributes
  end

  def self.attributes
  	@attributes
  end

  def self.parse_all(results)
  end

  def initialize(params = {})
  	params.each_pair do |attr_name, value|
  		if self.class.attributes.include?(attr_name.to_sym)
  			send("#{attr_name}=", value)
  		else
  			raise "mass assignment to unregistered attribute #{attr_name}"
  		end
  	end

  end
end
