require 'thor'
require 'faker'
require 'tod'
require 'tod/core_extensions'
require 'active_support'
require 'active_support/core_ext'
require 'awesome_print'

module Ittan
  def self.input_dummy_data(column, file)
    column_name = column.match("\"[a-zA-Z0-9_]*\"")[0].delete("\"")
    file.puts "#{column_name}: #{Ittan::create_string_dummy(column)},"  if column.include?('t.string')
    file.puts "#{column_name}: #{Ittan::create_text_dummy},"            if column.include?('t.text')
    file.puts "#{column_name}: #{Ittan::create_integer_dummy(column)}," if column.include?('t.integer')
    file.puts "#{column_name}: #{Ittan::create_float_dummy(column)},"   if column.include?('t.float')
    file.puts "#{column_name}: #{Ittan::create_decimal_dummy(column)}," if column.include?('t.decimal')
    file.puts "#{column_name}: #{Ittan::create_boolean_dummy},"         if column.include?('t.boolean')
    file.puts "#{column_name}: #{Ittan::create_date_dummy},"            if column.include?('t.date ')
    file.puts "#{column_name}: #{Ittan::create_time_dummy},"            if column.include?('t.time')
    file.puts "#{column_name}: #{Ittan::create_datetime_dummy},"        if column.include?('t.datetime')
  end

  def self.create_string_dummy(column)
    limit = column.match("(limit: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    limit_random = rand(1..limit)
    "\"#{Faker::Lorem.characters(limit_random)}\""
  end

  def self.create_text_dummy
    "\"Faker::Lorem.sentence\""
  end

  def self.create_integer_dummy(column)
    limit = column.match("(limit: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    limit_random = rand(1..limit)
    Faker::Number.number(limit_random)
  end

  def self.create_float_dummy(column)
    limit = column.match("(limit: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    limit_random = rand(1..limit)
    Faker::Number.decimal(limit_random)
  end

  def self.create_decimal_dummy(column)
    precision = column.match("(precision: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    scale = column.match("(scale: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
    if scale.nil?
      integer_part = rand(1..precision - 1)
      decimal_part = precision - integer_part
    else
      decimal_part = scale
      integer_part = precision - decimal_part
    end
    Faker::Number.decimal(integer_part, decimal_part)
  end

  def self.create_date_dummy
    "\"Faker::Date.between(Date.today, Date.today)\""
  end

  def self.create_time_dummy
    "\"Time.now.to_time_of_day\""
  end

  def self.create_datetime_dummy
    "\"Faker::Time.between(DateTime.now, DateTime.now)\""
  end

  def self.create_boolean_dummy
    Faker::Boolean.boolean
  end

  class CLI < Thor
    default_command :create

    desc "create", "create dummy data."
    # method_option :type, aliases: '-t', default: 'seed_fu', type: :string, desc: "Select seed type. (seed or seed_fu)"
    def create(file_path = 'db/schema.rb')
      begin
        File.open(file_path) do |file|
          file.read.split("create_table").each_with_index do |table, index|
            next if index == 0 # skip comment

            # divide table_name from column
            table_content = table.split("do |t|")
            table_info = table_content.shift
            table_name = table_info.match(/\"[a-zA-Z_]*\"/)[0].delete("\"")
            model_name = table_name.classify

            # input file
            fixtures_path = "db/fixtures"
            seed_file_path = "#{fixtures_path}/#{table_name}.rb"

            FileUtils.mkdir_p(fixtures_path) unless FileTest.exist?(fixtures_path)
            File.open(seed_file_path, "w") do |seed_file|
              seed_file.puts "#{model_name}.seed(\n:id,\n{\n" # input file header
              table_content[0].split("\n").each do |row|
                next unless row.include?("t.") # skip except column
                Ittan::input_dummy_data(row, seed_file)
              end
              seed_file.puts "},\n)"
            end
          end
        end
      rescue SystemCallError => e
        puts %Q(class=[#{e.class}] message=[#{e.message}])
      rescue IOError => e
        puts %Q(class=[#{e.class}] message=[#{e.message}])
      end
    end
  end
end