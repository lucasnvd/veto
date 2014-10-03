# Veto

Veto provides lightweight validation for plain old ruby objects, using a familiar DSL.

Tested on the following Rubies: MRI 2.0.0, 1.9.3

[![Build Status](https://travis-ci.org/kodio/veto.png)](https://travis-ci.org/kodio/veto)

## Installation

Add this line to your application's Gemfile:

```
gem 'veto'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install veto
```
## Usage

```ruby
# Create a validator
class PersonValidator
    include Veto.validator
    
    validates :name, :presence => true
    validates :age, :inclusion => 0..100
end

# Create an entity
class Person
    attr_reader :name, :age, :errors
end

person = Person.new 

# Validate entity

validator = PersonValidator.new
validator.valid?(person) # => false
validator.validate!(person) # => # => Veto::InvalidEntity, ["name is not present", "..."]  
validator.errors.full_messages # => ["first name is not present", "..."]

# If entity has errors attr_accessor, errors will be passed to the entity

person.errors # => nil
validator = PersonValidator.new
validator.valid?(person) # => false
person.errors.full_messages # => ["first name is not present", "..."]
```

## Validation Helpers

### Presence
Likely the most used validation helper, the `presence` helper will check that the specified object attribute is not blank. Object attributes that are nil, or respond to `empty?` and return true, are considered blank. All other values will be considered present. This means that `presence` helper is safe to use for boolean attributes, where you need to ensure that the attribute value can be true or false, but not nil.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :presence => true
end
```

### Not Null
Similar to the `presence` helper, the `not_null` helper will strictly check that the specified attribute is not null/nil. Any attribute where `nil?` returns true is considered null. Other values, including blank strings and empty arrays, are all considered not-null and will pass.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :not_null => true
end
```
    
### Format
The `format` helper ensures that the string value of an attribute matches the specified regular expression. It's useful for ensuring that email addresses, URLs, UPC codes, ISBN codes, and the like, are in a specific format. It can also be used to check that only certain characters are used in the string.

```ruby
class PersonValidator
    include Veto.validator

    validates :email, :format => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    
        # OR
    
    validates :email, :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }

end
```
    
### Inclusion
This helper ensures that an attribute is included in a specified set, or range of values.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :role, :inclusion => [:webmaster, :admin, :user]
    
        # OR
    
    validates :role, :inclusion => { :in => [:webmaster, :admin, :user] }
end
```   

### Integer
This helper checks that the specified attribute can be a valid integer. For example, the values `123` and `'123'` will both pass, but `123.4` and `'123.4'` will both fail.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :age, :integer => true    
end
```

### Numeric
This helper checks that the specified attribute can be a valid float. For example, the values `123.4` and `'123.4'` will both pass.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :height, :numeric => true    
end
```

### Greater Than
This helper checks that the specified attribute can be a valid float which is greater than a specified value.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :age, :greater_than => 12    
end
```

### Greater Than Or Equal To
This helper checks that the specified attribute can be a valid float which is greater than or equal to a specified value.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :age, :greater_than_or_equal_to => 12    
end
```

### Less Than
This helper checks that the specified attribute can be a valid float which is less than a specified value.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :age, :less_than => 11   
end
```

### Less Than Or Equal To
This helper checks that the specified attribute can be a valid float which is less than or equal to a specified value.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :age, :less_than_or_equal_to => 11   
end
```

### Exact Length
This helper checks that an attribute is an exact length in characters.

```ruby
class BookValidator
    include Veto.validator
    
    validates :isbn, :exact_length => 17
    
        # OR
        
    validates :isbn, :exact_length => { :with => 17 }
end
```

### Max Length
This helper checks that an attribute does not exceed a given maximum character length.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :max_length => 10
    
        # OR
        
    validates :first_name, :max_length => { :with => 10 }
end
```

### Min Length
This helper checks that an attribute is longer than a given minimum character length.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :min_length => 3
    
        # OR
        
    validates :first_name, :min_length => { :with => 3 }
end
```

### Length Range
This helper checks that the length of an attribute falls within a given range, or other object that responds to `include?`

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :length_range => 3..10
    
        # OR
        
    validates :first_name, :length_range => { :in => 3..10 } 
end
```

## Common Validation Options
### message

The `:message` option allows you to specify the error message that will be added to the errors object when validation fails.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :presence => {:message => "has not been set"}
end
```

### on

The `:on` options allows you to specify which attribute name a given validation error should be applied to.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :presence => {:on => :last_name}
end

person = Person.new
validator = PersonValidator.new
validator.validate!(person) # => Veto::InvalidEntity, ["last_name is not present"]  
```

## Conditional Validation

You may want a validation to run only when a specified condition is satisfied. To accomplish this, you can pass `:if` and `:unless` options to the validators. Passing an `:if` condition to a validator will ensure that the validation is **only** run if the condition returns true. Passing an `:unless` condition to a validator will ensure that the validation is **always** run unless the condition returns true.

### Using a symbol with :if and :unless

Passing a symbol to the :if or :unless option will call the corresponding validator method upon validation.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :last_name, :presence => true, :if => :first_name_set?
    
    def first_name_set?(entity)
        entity.first_name
    end
end
```

### Using a proc with :if and :unless

A Proc object passed to an :if or :unless condition will be run during validation. The Proc object will receive the entity being validated as an argument.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :last_name, :presence => true, :unless => Proc.new{|person| person.first_name.nil? }
end
```

### Using a string with :if and :unless

A string passed to the :if or :unless option will be evaluated in the context of the entity being validated.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :last_name, :presence => true, :unless => "first_name.nil?"
end
```

### Grouping Conditional Validations

To conditionally run a block of validations, nest them inside a `with_options` method.

```ruby
class PersonValidator
    include Veto.validator
    
    with_options :if => :person_is_admin? do
        validates :admin_secret_code. :presence => true
        validates :admin_level, :inclusion => [3,4,5]
    end
    
    def person_is_admin?(entity)
        entity.is_admin
    end
end
```
 
### Combining Conditional Statements

You can use multiple `:if` and `:unless` statements together simultaneously in an array. The condition will pass only if all `:if` conditionals return true, and no `:unless` statements return true.

```ruby
class PersonValidator
    include Veto.validator
    
    validates :first_name, :presence => true, 
                           :if => [:person_has_name?, Proc.new{|person| person.is_human?}], 
                           :unless => ["nameless?", :skip_name_validation?]
end
```

### Conditional Locations

Conditional statements can be assigned as an options hash to the `with_options` method, the `validates` method, or an an options hash for an individual validator in the `validates` method.

```ruby
class PersonValidator
    include Veto.validator
    
    with_options :if => :my_condition_1
        validates :first_name. :presence => true, :min_length => 3, :if => :my_condition_2
        validates :last_name, :presence => {:unless => :my_condition_3}, :min_length => 3
    end
end
```

## Custom Validation

Veto provides a few ways to create your own validators and validation methods, when your needs are too complex for the built-in validation syntax.

### Custom Methods

You can use a method to check the current state of the entity, and add custom error messages to the errors object if the entity is invalid. Register these methods using the `validate` method. Multiple validation methods can be assigned at once, as well as a hash of condition options included as the last method argument.

```ruby
class PersonValidator
    include Veto.validator
    
    validate :supervisor_must_have_supervisor_code, :admins_have_last_names
    
    def supervisor_must_have_supervisor_code(entity)
        if entity.is_admin? && entity.employees.size > 0 && entity.supervisor_code.nil?
            errors.add(:supervisor_code, "can't be blank")
        end
    end
    
    def admins_have_last_names(entity)
        if entity.is_admin? && entity.last_name
            errors.add(:last_name, "can't be blank")
        end
    end
end
```

### Custom Attribute Checker

Much like the built-in `presence`, `max_length`, and `format` attribute checkers, you can create your own custom checker, and refer to it using the `check` method. Custom attribute checkers must extend the Veto::AttributeChecker class, implement a `check` method which receives 4 arguments: attribute, value, errors, and options.

```ruby
module Veto
    class IsStringCheck < AttributeCheck
        def check(attribute, value, errors, options={})
            on = options.fetch(:on, attribute)
            unless value.is_a?(String)
                errors.add(on, "is not a string")
            end     
        end
    end
end
```

## Configuration

Call the Veto `configure` method to yield the configuration object.

```ruby
Veto.configure do |c|
    ...
end
```   

### Messages

The `message` configuration object, allows you to change the default error message produced by each attribute validator. The message must be in the form of a lambda or Proc, and may or may not receive an argument. Use the example below for reference when customizing messages.

```ruby
Veto.configure do |c|
    c.message.set(:exact_length, lambda{|exact| "is not #{exact} characters"})
    c.message.set(:format, lambda{"is not valid"})
    c.message.set(:inclusion, lambda{|set| "is not in set: #{set.inspect}"})
    c.message.set(:integer, lambda{"is not a number"})
    c.message.set(:length_range, lambda{"is too short or too long"})
    c.message.set(:max_length, lambda{|max| "is longer than #{max} characters"})
    c.message.set(:min_length, lambda{|min| "is shorter than #{min} characters"})
    c.message.set(:not_null, lambda{"is not present"})
    c.message.set(:numeric, lambda{"is not a number"})
    c.message.set(:presence, lambda{"is not present"})
end
```

If you would like to change the default message produced by a specified validator, you can do so using through the configuration object.

Create a new validator by including the Veto validator module in your class.

```ruby
class PersonValidator
    include Veto.validator
end
```    
    
## Working With Errors

Veto's simple errors object is a subclass of hash, with a few additional methods for inspecting the collection of error messages.
    
#### errors.add
Adds a method to the errors object.

```ruby
errors.add(:first_name, "is not present")
```   

#### errors.empty?
Returns a boolean value representing if the errors object is empty or not.

```ruby
errors.empty? # => true
errors.add(:first_name, "is not present")
errors.empty? # => false
```

#### errors.count
Returns the number of errors present in the errors object.

```ruby
errors.count # => 0
errors.add(:first_name, "is not present")
errors.count # => 1
```

#### errors.on
Returns a list of error message for a given attribute.

```ruby
errors.on(:first_name) # => nil
errors.add(:first_name, "is not present")
errors.add(:first_name, "is too short")
errors.on(:first_name) # => ["is not present", "is too short"]
```

#### errors.full_messages
Returns a list of full error messages.

```ruby
errors.add(:first_name, "is not present")
errors.add(:last_name, "is too short")
errors.full_messages # => ["first_name is not present", "last_name is too short"]
```

## Veto Model

If your entities and validators have a strict 1-to-1 relationship (an entity will only ever be validated by a single validator, and a validator will only ever validate a single entity), it might make sense to embed the validator directly inside the entity.

The Veto Model extension does exactly this, associating your entity with a specified validator, and adding 3 additional methods to your entity: `valid?`, `validate!`, and `errors`

```ruby
class Person
    include Veto.model(PersonValidator.new)
end

person.new
person.valid? # => false
person.errors.full_messages # => ["first name is not present", "last name is not present"]
person.validate! # => Veto::InvalidEntity, ["first name is not present", "..."]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request