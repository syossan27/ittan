require 'faker'
require 'tod'
require 'tod/core_extensions'

module Ittan
  class Column
    attr_accessor :text, :seed_file, :name

    def initialize(column_text, seed_file)
      @text = column_text
      @seed_file = seed_file
      @name = extract_column_name
    end

    def input_dummy_data
      input_file create_string_dummy    if @text.include?('t.string')
      input_file create_text_dummy      if @text.include?('t.text')
      input_file create_integer_dummy   if @text.include?('t.integer')
      input_file create_float_dummy     if @text.include?('t.float')
      input_file create_decimal_dummy   if @text.include?('t.decimal')
      input_file create_boolean_dummy   if @text.include?('t.boolean')
      input_file create_date_dummy      if @text.include?('t.date ')
      input_file create_time_dummy      if @text.include?('t.time')
      input_file create_datetime_dummy  if @text.include?('t.datetime')
    end

    private

    def extract_column_name
      @text.match("\"[a-zA-Z0-9_]*\"")[0].delete("\"")
    end

    def extract_column_limit
      @text.match("(limit: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    end

    def extract_column_precision
      @text.match("(precision: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    end

    def extract_column_scale
      @text.match("(scale: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    end

    def create_string_dummy
      limit = extract_column_limit
      limit_random = rand(1..limit)
      "\"#{Faker::Lorem.characters(limit_random)}\""
    end

    def create_text_dummy
      "\"#{Faker::Lorem.sentence}\""
    end

    def create_integer_dummy
      limit = extract_column_limit
      limit_random = rand(1..limit)
      Faker::Number.number(limit_random)
    end

    def create_float_dummy
      limit = extract_column_limit
      limit_random = rand(1..limit)
      Faker::Number.decimal(limit_random)
    end

    def create_decimal_dummy
      precision = extract_column_precision
      scale = extract_column_scale
      if scale.nil?
        integer_part = rand(1..precision - 1)
        decimal_part = precision - integer_part
      else
        decimal_part = scale
        integer_part = precision - decimal_part
      end
      Faker::Number.decimal(integer_part, decimal_part)
    end

    def create_date_dummy
      "\"Faker::Date.between(Date.today, Date.today)\""
    end

    def create_time_dummy
      "\"#{Time.now.to_time_of_day}\""
    end

    def create_datetime_dummy
      "\"#{Faker::Time.between(DateTime.now, DateTime.now)}\""
    end

    def create_boolean_dummy
      Faker::Boolean.boolean
    end

    def input_file(dummy_data)
      @seed_file.puts "#{@name}: #{dummy_data},"
    end
  end
end
