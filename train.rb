# frozen_string_literal: true
TRAIN_NUMBER = /^(([а-яА-Я]{3}||\d{3})-*([а-яА-Я]{2}||\d{2}))$/.freeze

class Train

  include ProduceCompany
  include InstanceCounter
  include Validation
  include Accessors
  attr_reader :train_type, :stations_on_route, :trains, :train_carriage, :type, :taken, :full_carriage_value

  attr_accessor_with_history :speed
  attr_accessor_strong :number

  @@trains = []
  Train.set_instances
  Train.set_register_instances

  def self.find_train(number)
    @@trains.find { |train| train.number == number }
  end

  def initialize(number, _full_carriage = 0)
    @speed = 0
    @number = number.to_s
    validate!
    @@trains << self
    @train_carriage = []
  end

  def train_carriage_print(&block)
    @train_carriage.each.with_index(&block)
  end

  def taken_volume_seats(taken_volume = 1)
    @taken += taken_volume.to_i
  end

  def free_seats_volume(&block)
    block.call(full_carriage_value, taken)
  end

  def train_speed_up
    @speed += 50
  end

  def stop_train
    @speed = 0
  end

  def carriage_number
    @train_carriage.length
  end

  def add_carriage(carriage)
    train_stopped?
    @train_carriage << carriage
  end

  def remove_carriage
    train_stopped?
    @train_carriage.pop
  end

  def train_route(route)
    put_train_to_begining(route)
    move_to_first_station
  end

  def moving_forward
    return unless not_last_station?

    leave_current_station
    @current_station += 1
    move_next_station
  end

  def moving_back
    return unless not_first_station?

    leave_current_station
    @current_station -= 1
    move_next_station
  end

  def current_train_position
    print_station if not_first_station?
    return unless not_last_station?

    print_next_station
  end

  protected

  def train_stopped?
    @speed.zero?
  end

  def put_train_to_begining(route)
    @stations_on_route = []
    @current_station = 0
    @stations_on_route = route.stations
  end

  def print_station
    puts "Поезд находится на станции: #{@stations_on_route[@current_station].name}"
    puts "Предыдущая станция: #{@stations_on_route[@current_station - 1].name}"
  end

  def print_next_station
    puts "Следующая станция: #{@stations_on_route[@current_station + 1].name}"
  end

  def move_to_first_station
    @stations_on_route[0].come_in_trains(self)
  end

  def leave_current_station
    @stations_on_route[@current_station].leave_station(self)
  end

  def not_last_station?
    @current_station < @stations_on_route.length - 1
  end

  def not_first_station?
    @current_station >= 1
  end

  def move_next_station
    @stations_on_route[@current_station].come_in_trains(self)
  end

end
