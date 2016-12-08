require 'active_support'
require 'active_support/core_ext'

module Ittan
  class Table
    attr_accessor :content, :name, :model_name, :fixtures_path, :seed_file_path, :seed_file

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
          @seed_file = seed_file
          input_seed_file
        end

        puts %Q(\e[32mcreate: #{@seed_file_path}\e[0m) # Create Message
      rescue SystemCallError, IOError => e
        puts %Q(\e[31mError: #{e.message}\e[0m) # Error Message
      end
    end

    private

    def input_seed_file
      @seed_file.puts "#{@model_name}.seed(\n:id,\n{\n" # file header

      @content[0].split("\n").each do |column_text|
        next unless column_text.include?("t.") # skip except column
        column_instance = Ittan::Column.new(column_text, @seed_file)
        column_instance.input_dummy_data
      end

      @seed_file.puts "},\n)" # file footer
    end
  end
end
