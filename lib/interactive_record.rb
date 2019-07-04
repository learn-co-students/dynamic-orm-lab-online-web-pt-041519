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

    def col_names_for_insert
        self.class.column_names.delete_if {|colnam| colnam == "id"}.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |colnam|
          values << "'#{send(colnam)}'" unless send(colnam).nil?
        end
        values.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = '#{name}'")
    end

    def self.find_by(options)
        options.map do |key, value|
            sql = "SELECT * FROM #{self.table_name} WHERE #{key} = '#{value}'"
            @result = DB[:conn].execute(sql)
        end
        @result.flatten
    end

end