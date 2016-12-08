require 'thor'

module Ittan
  class CLI < Thor
    default_command :create

    desc "create", "create dummy data."
    # method_option :type, aliases: '-t', default: 'seed_fu', type: :string, desc: "Select seed type. (seed or seed_fu)"
    def create(schema_file_path = 'db/schema.rb')
      begin
        File.open(schema_file_path) do |schema_file|
          tables = schema_file.read.split("create_table")
          tables.each_with_index do |table, index|
            next if index == 0 # skip comment

            table_instance = Ittan::Table.new(table)
            table_instance.create_fixtures_directory
            table_instance.create_seed_file
          end
        end
      rescue SystemCallError, IOError => e
        puts %Q(\e[31mError: #{e.message}\e[0m)
      end
    end
  end
end