require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  ## CLASS METHODS
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].execute("PRAGMA table_info (#{self.table_name})").map { |column| column["name"] }
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attrs)
    attr_key = attrs.keys[0].to_s
    sql = "SELECT * FROM #{self.table_name} WHERE #{attr_key} = ?"
    DB[:conn].execute(sql, attrs.values[0])
  end


  ## INSTANCE METHODS
  def initialize(attributes = {})
    attributes.each { |attr, value| self.send("#{attr}=", value) }
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |column| column == "id" }.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each { |column| values << "'#{send(column)}'" unless send(column) == nil }
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    self
  end
end
