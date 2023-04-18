# frozen_string_literal: true

require_relative 'acсessors'
require_relative 'validation'
require_relative 'produce_company'
require_relative 'instance_counter'
require_relative 'train'
require_relative 'station'
require_relative 'route'
require_relative 'passenger_train'
require_relative 'passenger_carriage'
require_relative 'cargo_train'
require_relative 'cargo_carriage'

class Menu
  def initialize
    @stations = []
    @routes = []
    @trains = []
  end

  def change_speed
    choose_train
    speed_changing
  end

  def speed_history
    choose_train
    show_speed_history
  end

  def train_information
    puts 'Выберите поезд'
    @stations[@num_stat].trains_list(@block_station)
    @num_train = gets.chomp.to_i
    print_carriages
  end

  def taken_seats_or_value
    choose_train
    choose_carriage
    train_type_passenger? ? take_seat : take_volume
  end

  def trains_on_station
    choose_station
    puts 'Сейчас на станции находятся следующие поезда:'
    @stations[@num_stat].trains_list { |train, index| puts "#{index} - #{train.number}:#{train.train_type}" }
    puts "Всего #{@stations[@num_stat].total_trains_number} поезда"
  end

  def create_station
    begin
      puts 'Введите название станции.Название вводится кирилицей, первая буква - заглавная, неменее 3 букв'
      name = gets.chomp
      station = Station.new(name)
    rescue StandardError => e
      puts "Error #{e.inspect}"
      retry
    end
    @stations << station
    puts "Создан объект - #{station.name}"
  end

  def create_passenger_train
    begin
      puts 'Введите номер пассажирского поезда'
      puts 'Номер(кирилица) -3 буквы или цифры в любом порядке+необязательный дефис+2 буквы или цифры'
      train = PassengerTrain.new(gets.chomp)
    rescue StandardError => e
      puts "Error #{e.inspect}"
      retry
    end
    train.produce_company
    @trains << train
  end

  def create_cargo_train
    begin
      puts 'Введите номер грузового поезда'
      puts 'Номер(кирилица)-3 буквы или цифры в любом порядке+необязательный дефис+2 буквы или цифры'
      train = CargoTrain.new(gets.chomp)
    rescue StandardError => e
      puts "Error #{e.inspect}"
      retry
    end
    train.produce_company
    @trains << train
  end

  def create_route
    begin
      new_stations_list
      puts 'Введите номер первой станции маршрута'
      first = gets.chomp.to_i
      puts 'Введите номер последней станции маршрута'
      last = gets.chomp.to_i
      route = Route.new(@stations[first], @stations[last])
    rescue StandardError => e
      puts "Error #{e.inspect}"
      retry
    end
    @routes << route
    route.show_route
  end

  def edite_route_add_station
    puts 'Выберите номер маршрута для редактирования'
    choose_route
    choose_station
    puts "#{@stations[@num_stat].name} будет добавлена в маршрут"
    @routes[@num_route].add_station(@stations[@num_stat])
    @routes[@num_route].show_route
  end

  def edite_route_delete_station
    puts 'Вы берите номер маршрута для редактирования'
    choose_route
    choose_station
    puts "#{@stations[@num_stat].name} будет удалена из маршрута "
    @routes[@num_route].delete_station(@stations[@num_stat])
    @routes[@num_route].show_route
  end

  def set_route
    puts 'Выберите поезд для назначения маршрута'
    choose_train
    puts 'Выберите необходимый маршрут'
    choose_route
    @trains[@num_train].train_route(@routes[@num_route])
    puts "Поезду #{@trains[@num_train].number} назначен маршрут"
  end

  def move_train_forward
    puts 'Выберите поезд для перемещения'
    choose_train

    if train_has_route?
      puts 'Поезду не назначен маршрут'
    else
      @trains[@num_train].moving_forward
      @trains[@num_train].current_train_position
    end
  end

  def move_train_back
    puts 'Выберите поезд для перемещения'
    choose_train
    if !@trains[@num_train].stations_on_route.nil?
      @trains[@num_train].moving_back
      @trains[@num_train].current_train_position
    else
      puts 'Поезду не назначен маршрут'
    end
  end

  def new_stations_list
    Station.all_st
  end

  def add_carriages
    choose_train
    train_type_passenger? ? create_passenger_carriage : create_cargo_carriage
    add_new_carriage
  end

  def remove_carriage
    choose_train
    @trains[@num_train].remove_carriage(@trains[@num_train])
    @trains[@num_train].carriage_number
  end

  def find_train_with_number
    puts('Введите номер поезда')
    number = gets.chomp.to_s
    if Train.find_train(number).nil?
      puts ' NILL '
    else
      puts " Объект - #{Train.find_train(number)}"
    end
  end

  def create_passenger_carriage
    puts 'Введите количество мест в вагоне'
    full_carriage_value = gets.chomp.to_i
    @carr_pass = PassengerCarriage.new(full_carriage_value)
    @carr_pass.produce_company
    puts 'Создан passenger вагон'
  end

  def create_cargo_carriage
    puts 'Введите общий объем вагона'
    full_carriage_value = gets.chomp.to_i
    @carr_cargo = CargoCarriage.new(full_carriage_value)
    @carr_cargo.produce_company
    puts 'Создан cargo вагон'
  end

  protected

  def show_speed_history
    puts "Скорость:"
    array = @trains[@num_train].speed_history
    array.each {|i| puts i}
  end

  def speed_changing
    puts "введите скорость"
    speed=gets.chomp.to_i
    @trains[@num_train].speed=speed
    puts "Скорость: #{@trains[@num_train].speed}"
  end

  def train_has_route?
    @trains[@num_train].stations_on_route.nil?
  end

  def take_seat
    @trains[@num_train].train_carriage[@carr_num].taken_volume_seats
    puts 'Занято 1 место'
  end

  def take_volume
    puts 'Введите объем груза'
    volume = gets.chomp.to_i
    @trains[@num_train].train_carriage[@carr_num].taken_volume_seats(volume)
    puts 'В вагон добавлен груз '
  end

  def print_carriages
    @trains[@num_train].train_carriage_print do |carriage, index|
      puts "#{index}-вагон:#{carriage.type}"
      puts "Всего #{carriage.full_carriage_value}"
      puts "Занято #{carriage.taken}"
      carriage.free_seats_volume { |x, y| puts "Свободно #{x - y}" }
    end
  end

  def choose_carriage
    puts 'Выберите вагон'
    print_carriages
    @carr_num = gets.chomp.to_i
  end

  def add_new_carriage
    if train_type_passenger?
      @trains[@num_train].add_carriage(@carr_pass)
    else
      @trains[@num_train].add_carriage(@carr_cargo)
    end
    @trains[@num_train].carriage_number
  end

  def train_type_passenger?
    @trains[@num_train].train_type == :passenger
  end

  def choose_train
    puts 'Выберите поезд'
    all_trains_list
    @num_train = gets.chomp.to_i
    puts "Поезд #{@trains[@num_train].number} - #{@trains[@num_train].train_type}"
  end

  def all_trains_list
    @trains.each_with_index { |train, index| puts "#{index} - <<#{train.number}>>" }
  end

  def new_routes_list
    @routes.each_with_index do |route, index|
      print "#{index} - "
      route.show_route
    end
  end

  def choose_route
    new_routes_list
    @num_route = gets.chomp.to_i
  end

  def choose_station
    puts 'Выберите номер станции '
    new_stations_list
    @num_stat = gets.chomp.to_i
  end
end

menu = Menu.new

menu_hash = [
  { index: 1, title: 'Создать станцию', action: :create_station },
  { index: 2, title: 'Создать пассажирский поезд', action: :create_passenger_train },
  { index: 3, title: 'Создать грузовой поезд', action: :create_cargo_train },
  { index: 4, title: 'Создать маршрут', action: :create_route },
  { index: 5, title: 'Редактировать маршрут, добавить станцию', action: :edite_route_add_station },
  { index: 6, title: 'Редактировать маршрут, удалить станцию', action: :edite_route_delete_station },
  { index: 7, title: 'Назначать маршрут поезду', action: :set_route },
  { index: 8, title: 'Добавить вагоны к поезду', action: :add_carriages },
  { index: 9, title: 'Отцепить вагон от поезда', action: :remove_carriage },
  { index: 10, title: 'Переместить поезд по маршруту вперед', action: :move_train_forward },
  { index: 11, title: 'Переместить поезд по маршруту назад', action: :move_train_back },
  { index: 12, title: 'Просмотреть список станций', action: :new_stations_list },
  { index: 13, title: 'Просмотреть список поездов на станции', action: :trains_on_station },
  { index: 14, title: 'Найти поезд по номеру', action: :find_train_with_number },
  { index: 16, title: 'Занять места (:passenger) или объем (:cargo)', action: :taken_seats_or_value },
  { index: 15, title: '', action: :train_information },
  { index: 17, title: 'Изменить скорость', action: :change_speed },
  { index: 18, title: 'История изменения скорости', action: :speed_history }
]
menu_hash.each.each { |item| puts "#{item[:index]} - #{item[:title]}" }

loop do
  mark = gets.to_i
  find_item = menu_hash.find { |item| item[:index] == mark }
  menu.send(find_item[:action]) unless find_item.nil?
  puts 'Выберите следующее действие'
  break if mark.zero?
end
