module Veto
  module Validator
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def with_options(*args, &block)
        checker.with_options(*args, &block)
      end

      def validates(*args)
        checker.validates(*args)
      end

      def validate(*args)
        checker.validate(*args)
      end

      def check_with(val)
        @checker = val
      end

      def checker
        @checker ||= build_checker
      end

      private

      def build_checker(children=[])
        Checker.from_children(children)
      end

      # Ensures that when a Validator class is subclassed, the 
      # validation rules will be carried into the subclass as well,
      # where they may be added upon.
      # 
      # @example
      #   class PersonValidator
      #     include Veto.validator
      #     validates :name, :presence => true
      #   end
      #
      #   class EmployeeValidator < PersonValidator
      #     validates :employee_id, :presence => true
      #   end
      #
      #   employee = Employee.new
      #   validator = EmployeeValidator.new
      #   validator.validate!(employee) # => ["name is not present", "employee_id is not present"]

      def inherited(descendant)
        descendant.check_with(build_checker(checker.children.dup))
      end
    end

    def errors
      @errors ||= ::Veto::Errors.new
    end

    # Sets errors to nil. 
    def clear_errors
      @errors = nil
    end

    # Returns boolean value representing the validaty of the entity
    #
    # @return [Boolean]
    def valid?(entity)
      validate(entity)
      errors.empty?
    end

    # Raises exception if entity is invalid
    #
    # @example
    #   person = Person.new
    #   validator = PersonValidator.new
    #   validator.validate!(person) # => Veto::InvalidEntity, ["first name is not present", "..."]    
    #
    # @raise [Veto::InvalidEntity] if the entity is invalid
    def validate!(entity)
      raise(::Veto::InvalidEntity, errors) unless valid?(entity)
    end

    private

    def validate(entity)
      clear_errors
      self.class.checker.call(CheckContextObject.new(entity, self, errors))
      populate_entity_errors(entity)
    end

    def populate_entity_errors(entity)
      if entity.respond_to?(:errors=)
        entity.errors = errors
      end
    end
  end
end