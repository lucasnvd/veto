module Veto
	class MaxLengthCheck < AttributeCheck
		def check(attribute, value, errors, options={})
			max = options.fetch(:with)
			message = options.fetch(:message, :max_length)
			on = options.fetch(:on, attribute)
			
			if value.nil? || value.length > max
				errors.add(on, message, max)
			end
		end
	end
end