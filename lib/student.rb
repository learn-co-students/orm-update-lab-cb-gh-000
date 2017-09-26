require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  # Creates students table in the database
  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  # Drops students table from the database
  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  # Creates a new Student object from a hash of attributes
  # and saves the student to the database
  def self.create(name, grade)
    @name = name
    @grade = grade

    student = self.new(name, grade)

    student.save
    student
  end

  # Saves an instance of the Student class to the database
  # Or updates database if Student already exists in database
  def save
    if self.id
      self.update
    else
      sql_insert = 'INSERT INTO students (name, grade) VALUES (?, ?)'
      DB[:conn].execute(sql_insert, @name, @grade)

      sql_select_last = 'SELECT last_insert_rowid() FROM students'
      @id = DB[:conn].execute(sql_select_last)[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  # This class method takes an argument of an array.
  # Argument is the row returned from the database by the execution of a SQL query.
  # Row contains the id, name and grade of a student.
  # The .new_from_db method uses these three array elements to create a new Student object with these attributes.
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]

    self.new(id, name, grade)
  end

  # This class method takes in an argument of a name.
  # It queries the database table for a record
  # that has a name of the name passed in as an argument.
  # Then it uses the #new_from_db method to instantiate a Student object
  # with the database row that the SQL query returns.
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, grade
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end
end




