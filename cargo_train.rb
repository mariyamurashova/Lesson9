# frozen_string_literal: true

class CargoTrain < Train

  validate :number, :format, TRAIN_NUMBER
  validate :number, :presence

  CargoTrain.set_instances
  CargoTrain.set_register_instances

  def initialize(number)
    super
    @train_type = :cargo
  end
end
