# frozen_string_literal: true

class PassengerTrain < Train
  
  validate :number, :format, TRAIN_NUMBER
  validate :number, :presence

  PassengerTrain.set_instances
  PassengerTrain.set_register_instances

  def initialize(number)
    super
    @train_type = :passenger
  end
end
