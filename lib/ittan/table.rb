module Ittan
  class Table
    attr_accessor :content, :name, :model_name, :fixtures_path, :seed_file_path

    def initialize(table_sentence)
      # divide table_name from column
      @content = table_sentence.split("do |t|")
      @name = @content.shift.match(/\"[a-zA-Z_]*\"/)[0].delete("\"")
      @model_name = @name.classify

      # input file
      @fixtures_path = "db/fixtures"
      @seed_file_path = "#{@fixtures_path}/#{@name}.rb"
    end

    def create_fixtures_directory
      FileUtils.mkdir_p(@fixtures_path) unless FileTest.exist?(@fixtures_path)
    end

    def create_seed_file
      return if FileTest.exist?(@seed_file_path)
      begin
        File.open(@seed_file_path, "w") do |seed_file|
          seed_file.puts "#{@model_name}.seed(\n:id,\n{\n" # input file header
          @content[0].split("\n").each do |row|
            next unless row.include?("t.") # skip except column
            input_dummy_data(row, seed_file)
          end
          seed_file.puts "},\n)"
        end
      rescue SystemCallError => e
        puts %Q(class=[#{e.class}] message=[#{e.message}])
      rescue IOError => e
        puts %Q(class=[#{e.class}] message=[#{e.message}])
      end
    end

    private

    def input_dummy_data(column, file)
      column_name = column.match("\"[a-zA-Z0-9_]*\"")[0].delete("\"")
      file.puts "#{column_name}: #{create_string_dummy(column)},"  if column.include?('t.string')
      file.puts "#{column_name}: #{create_text_dummy},"            if column.include?('t.text')
      file.puts "#{column_name}: #{create_integer_dummy(column)}," if column.include?('t.integer')
      file.puts "#{column_name}: #{create_float_dummy(column)},"   if column.include?('t.float')
      file.puts "#{column_name}: #{create_decimal_dummy(column)}," if column.include?('t.decimal')
      file.puts "#{column_name}: #{create_boolean_dummy},"         if column.include?('t.boolean')
      file.puts "#{column_name}: #{create_date_dummy},"            if column.include?('t.date ')
      file.puts "#{column_name}: #{create_time_dummy},"            if column.include?('t.time')
      file.puts "#{column_name}: #{create_datetime_dummy},"        if column.include?('t.datetime')
    end

    def create_string_dummy(column)
      limit = column.match("(limit: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
      limit_random = rand(1..limit)
      "\"#{Faker::Lorem.characters(limit_random)}\""
    end

    def create_text_dummy
      "\"#{Faker::Lorem.sentence}\""
    end

    def create_integer_dummy(column)
      limit = column.match("(limit: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
      limit_random = rand(1..limit)
      Faker::Number.number(limit_random)
    end

    def create_float_dummy(column)
      limit = column.match("(limit: )[0-9]*") { |match_data| match_data[0].delete("^0-9").to_i }
      limit_random = rand(1..limit)
      Faker::Number.decimal(limit_random)
    end

    def create_decimal_dummy(column)
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
  end
end
