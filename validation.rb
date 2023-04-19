# frozen_string_literal: true
module Validation

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

module ClassMethods

  def validate(name, type, *param)    
    @validate_hash ||= []
    @validate_hash << {name: name, type: type, param: param} 
  end
end

module InstanceMethods

     
    def validate!(name, value)
      @validate_hash=Train.instance_variable_get(:@validate_hash)
      @variable_data_hash = {var_name: name, var_value: value}
      @validate_hash.each do |hash| 
        if hash[:name]== @variable_data_hash[:var_name] 
        send(:"validate_#{hash[:type]}", hash[:param])      
        end
      end
    end

    def validate_presence(param)
      raise "Variable #{@variable_data_hash[:var_name]}  presence is nil" if @variable_data_hash[:var_value].nil? || @variable_data_hash[:var_value].to_s.empty?
    end

    def validate_format(param)
      raise "Invalid format" if @variable_data_hash[:var_value].to_s !~ param[0]
    end

    def validate_type(param)
      raise "Variable #{@variable_data_hash[:var_name]} type must be #{param} " if  @variable_data_hash[:var_value].class == param
    end
    def valid?
      validation!
      true
      rescue StandardError
      false
    end
  end
end