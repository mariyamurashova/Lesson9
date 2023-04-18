# frozen_string_literal: true

module ProduceCompany
  attr_accessor :company_name

  def produce_company
    puts 'Введите название производителя'
    @company_name = gets.chomp
  end
end
