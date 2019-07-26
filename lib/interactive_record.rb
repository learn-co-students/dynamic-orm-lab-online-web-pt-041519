require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
=begin
achieves something like this:
	song = Song.new(name: "Hello", album: "25")
puts "song name: " + song.name
puts "song album: " + song.album
song.save

puts Song.find_by_name("Hello")
=end
  

def self.table_name
	# this takes the class name and turns it into a table name. weird.
	self.to_s.downcase.pluralize
end

def self.column_names
	# this takes the sql table, extracts the column names and puts it into an array. compact removes any nil values
	DB[:conn].results_as_hash = true

	sql = "pragma table_info('#{table_name}')"

	table_info = DB[:conn].execute(sql)
	column_names = []
	table_info.each do |row|
		column_names << row["name"]
	end
	column_names.compact
end

def initialize(options={})
	# loops through a given hash when you create a .new student and creates attribuets based on attr_accesors
	options.each do |property, value|
		self.send("#{property}=", value)
	end
end

def save
	sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
	DB[:conn].execute(sql)
	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

end


def table_name_for_insert
	# why do we need this and not using self.table_name, because you want to get the instance abstract saved table
	self.class.table_name
end






  def values_for_insert
  	# values get inserted from column_names, extract the attribuet value using send method gets the @attribute = value, value data
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
  	# remove id in save method because you don't save the id it gets automatically generated
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

def self.find_by_name(name)
	# finds by name a student, looks in sql database. can't use the question mark for some reason, need to use '#{name}'
  sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
  DB[:conn].execute(sql)
end







def self.find_by(attribute_hash)
	    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)

end





end