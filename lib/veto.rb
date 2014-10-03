module Veto
  # Provides access to the anonymous validator extension module
  #
  # @example 
  #   class PersonValidator
  #    include Veto.validator
  #   end 
  #
  # @return [Module] the object converted into the expected format.
  def self.validator
    mod = Module.new
    mod.define_singleton_method :included do |base|
      base.send(:include, ::Veto::Validator)
    end
    mod
  end

  # Provides access to the anonymous model extension module
  #
  # @example 
  #   class Person
  #    include Veto.model(PersonValidator.new)
  #   end 
  #
  # @param validator [Class] the Veto validator class
  # @return [Module] the object converted into the expected format.
  def self.model validator
    mod = Module.new
    mod.define_singleton_method :included do |base|
      base.send(:include, ::Veto::Model)
      base.validates_with validator
    end
    mod
  end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end

# base
require 'forwardable'
require 'veto/version'
require 'veto/exceptions'
require 'veto/errors'
require 'veto/configuration'
require 'veto/check_context_object'

# conditions
require 'veto/conditions/condition'
require 'veto/conditions/entity_eval_condition'
require 'veto/conditions/context_method_condition'
require 'veto/conditions/proc_condition'
require 'veto/conditions/primative_condition'
require 'veto/conditions/conditions'
require 'veto/conditions/if_conditions'
require 'veto/conditions/unless_conditions'
require 'veto/conditions/if_unless_conditions'
require 'veto/conditions/condition_factory'

# checks
require 'veto/checks/check'
require 'veto/checks/method_check'
require 'veto/checks/attribute_check'
require 'veto/checks/exact_length_check'
require 'veto/checks/format_check'
require 'veto/checks/greater_than_or_equal_to_check'
require 'veto/checks/greater_than_check'
require 'veto/checks/inclusion_check'
require 'veto/checks/integer_check'
require 'veto/checks/length_range_check'
require 'veto/checks/less_than_or_equal_to_check'
require 'veto/checks/less_than_check'
require 'veto/checks/max_length_check'
require 'veto/checks/min_length_check'
require 'veto/checks/not_null_check'
require 'veto/checks/numeric_check'
require 'veto/checks/presence_check'
require 'veto/checks/check_factory'

# validates
require 'veto/blocks/block'
require 'veto/blocks/conditional_block'
require 'veto/blocks/validate_block'
require 'veto/blocks/validates_block'
require 'veto/blocks/with_options_block'
require 'veto/blocks/checker'

# modules
require 'veto/validator'
require 'veto/model'