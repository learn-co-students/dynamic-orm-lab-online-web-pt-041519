require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        sql = "pragma table_info('#{table_name}')"
        t_data = DB[:conn].execute(sql)
        columns = []
        t_data.each do |arry|
        columns << arry["name"]
        end
        columns.compact
    end

    def initialize(options={})
        options.each do |property, value|
         self.send("#{property}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    
end