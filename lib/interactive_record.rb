require_relative "../config/environment.rb"
require 'active_support/inflector'
require'pry'
class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names #creates column names based off of the db table's column names
    DB[:conn].results_as_hash = true
    sql = <<-SQL
    PRAGMA table_info("#{table_name}")
    SQL
  # sql statement grabs a nested hash of the column info
    table_info = DB[:conn].execute(sql) #executes sql statement and stores to var
    column_names = []
    table_info.each do |column| #itterates nested hash storeing key name's value to an array for each column
      column_names << column["name"]
    end
    column_names.compact
  end


  def initialize(attributes={})
    attributes.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})"

    test1 = DB[:conn].execute(sql)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless
        send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if do |col_name|
      col_name == "id"
    end.join(", ")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys[0].to_s} = ?"
    DB[:conn].execute(sql, hash[hash.keys[0].to_sym])
  end

end
