# frozen_string_literal: true

module Accessors

  def self.included(base)
    base.extend ClassMethods
  end

module ClassMethods

  def attr_accessor_strong(*names)
    names.each do |name|
      var_name="@#{name}".to_sym
      define_method(name) {instance_variable_get(var_name)}
      define_method("#{name}=".to_sym) do |value| 
        validate!
        instance_variable_set(var_name, value) 
        rescue StandardError => e
        puts "Error #{e.inspect}"
      end
    end
  end

  def attr_accessor_with_history(*names)
    names.each do |name|
      var_values = "@#{name}_history".to_sym 
      array_history =[]
      var_name = "@#{name}".to_sym
        define_method(name) {instance_variable_get(var_name)}
        define_method("#{name}_history".to_sym) {instance_variable_get(var_values)}
        define_method("#{name}=".to_sym) do |value| 
          instance_variable_set(var_name, value)
          array_history << value
          instance_variable_set(var_values, array_history)  
         end
      end
    end 
  end
 end 