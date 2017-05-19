require_relative "../config/environment.rb"

class Student
  attr_accessor :name,:id,:grade

  def initialize(id=nil,name,grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    query = <<-SQL
      CREATE TABLE students(
        id integer primary key,
        name text,
        grade text
      )
    SQL

    DB[:conn].execute(query)
  end

  def self.drop_table
    query = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(query)
  end

  def save
    insert_query = <<-SQL
      INSERT INTO students(name,grade) VALUES (?,?)
    SQL

    update_query = <<-SQL
      UPDATE students SET name=? , grade=? where id=?
    SQL

    if @id == nil then
      DB[:conn].execute(insert_query,@name,@grade)
      @id = DB[:conn].last_insert_row_id
    else
      DB[:conn].execute(update_query,@name,@grade,@id)
    end

  end

  def self.create(name,grade)
    insert_query = <<-SQL
      INSERT INTO students(name,grade) VALUES (?,?)
    SQL

    DB[:conn].execute(insert_query,name,grade)
  end

  def self.new_from_db(row)
    s = self.new(row[0],row[1],row[2])
  end

  def self.find_by_name(name)
    query = <<-SQL
      SELECT * FROM students WHERE name=?
    SQL

    result = DB[:conn].execute(query,name).flatten
    s = self.new(result[0],result[1],result[2])
  end

  def update
    update_query = <<-SQL
      UPDATE students SET name=? , grade=? where id=?
    SQL

    DB[:conn].execute(update_query,@name,@grade,@id)
  end

end
