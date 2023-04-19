# frozen_string_literal: true

module Validation

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

module ClassMethods

  def validate(name, type, param=0)    
    @validate_hash ||= []
    @validate_hash << {name: name, type: type, param: param} 
  end
end

module InstanceMethods
     
  def validate!
    @validate_hash=self.class.instance_variable_get(:@validate_hash)
    @validate_hash.each do |hash| 
      variable = instance_variable_get("@#{hash[:name]}".to_sym)
      send(:"validate_#{hash[:type]}", variable, hash[:param])   
    end
  end

  def validate_presence(variable, param)
    raise "Variable #{variable}  presence is nil" if variable.nil? || variable.to_s.empty?
  end

  def validate_format(variable, param)
    raise "Invalid format" if variable.to_s !~ param
  end

  def validate_type(variable, param)
    raise "Variable #{variable} type must be #{param} " if  variable.class == param
  end

  def valid?
    validation!
    true
    rescue StandardError
    false
    end
  end
end