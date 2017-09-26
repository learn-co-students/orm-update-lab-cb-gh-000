require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def self.create_table
    sql=<<-SQL
      CREATE TABLE students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql="DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.create name, grade
    student = Student.new name, grade
    student.save
    student
  end

  def self.new_from_db row
    student = Student.new(row[1],row[2])
    student.instance_variable_set(:@id,row[0])
    student
  end

  def self.find_by_name name
    sql=<<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |student|
      new_from_db student
    end[0]
  end

  attr_accessor :name, :grade
  attr_reader :id

  def initialize name, grade
    @name = name
    @grade = grade
    @id = nil
  end

  def save
    return self.update if @id
    sql=<<-SQL
      INSERT INTO students (name,grade) VALUES (?,?)
    SQL
    DB[:conn].execute(sql,self.name,self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def update
    sql=<<-SQL
      UPDATE students SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end

  private

  def set_id id
    @id = id
  end

end
