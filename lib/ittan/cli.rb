require 'thor'
require 'faker'
require 'tod'
require 'tod/core_extensions'
require 'active_support'
require 'active_support/core_ext'
require 'awesome_print'

module Ittan

  class CLI < Thor
    default_command :create

    desc "create", "create dummy data."
    # method_option :type, aliases: '-t', default: 'seed_fu', type: :string, desc: "Select seed type. (seed or seed_fu)"
    def create(file_path = 'db/schema.rb')
      begin
        File.open(file_path) do |file|
          file.read.split("create_table").each_with_index do |table_sentence, index|
            next if index == 0 # skip comment

            table_instance = Ittan::Table.new(table_sentence)
            table_instance.create_fixtures_directory
            table_instance.create_seed_file
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