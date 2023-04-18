module InstanceCounter
  TRAIN_NUMBER = /^(([а-яА-Я]{3}||\d{3})-*([а-яА-Я]{2}||\d{2}))$/.freeze
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

module ClassMethods

  def validate(name, type, *param)    
    @validate_hash ||= []
    @validate_hash << {name: name, type: type, param: param} 
  end

  def attr_accessor_strong(*names)
    names.each do |name|
      var_name="@#{name}".to_sym

      define_method(name) {instance_variable_get(var_name)}

      define_method("#{name}=".to_sym) do |value| 
        validate!(name, value)
        instance_variable_set(var_name, value) 
        rescue StandardError => e
        puts "Error #{e.inspect}"
      end
    end
  end

  def attr_accessor_with_history(*names)
    names.each do |name|
      var_array = "@#{name}_history".to_sym 
      array_history =[]
      var_name = "@#{name}".to_sym

        define_method(name) {instance_variable_get(var_name)}

        define_method("#{name}_history".to_sym) {instance_variable_get(var_array)}
       
        define_method("#{name}=".to_sym) do |value| 
          instance_variable_set(var_name, value)
          array_history << value
          instance_variable_set(var_array, array_history)  
         end
      end
    end 
  end
 
  module InstanceMethods

    def validate!(name, value)
      @validate_hash=self.class.instance_variable_get("@validate_hash")
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
 
 class X
  
  include InstanceCounter
  attr_accessor_with_history :t, :i
  attr_accessor_strong :a, :b, :c
 
  
  validate :a, :type, String
  validate :a, :format, TRAIN_NUMBER
  validate :b, :presence
  validate :c, :type, Integer
  
end
 x=X.new
 x.a="fhfhjffj"
 x.b= nil
 x.c=45
 
 x.i=2
  x.t=6
  x.t=8
  puts "History t"
 x.t_history.each{|val| print "#{val}  "}
  x.i=9
  x.t=3
  puts""
  print x.instance_variables
  puts""
  puts "History i"
  x.i_history.each{|val| print "#{val}  "}

 
  
 