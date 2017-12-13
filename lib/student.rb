require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id = nil)
    self.name  = name
    self.grade = grade
    @id        = id
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
              INSERT INTO students (name, grade) VALUES (?, ?)
            SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?;", self.name, self.grade, self.id)
  end

  def self.create_table
    sql = <<-SQL
            CREATE TABLE IF NOT EXISTS students (
              id    INTEGER PRIMARY KEY,
              name  TEXT,
              grade TEXT
            );
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students;")
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    id, name, grade = row
    student = self.new(name, grade, id)
    student
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM students WHERE name = ?", name)[0]
    self.new_from_db(row)
  end
end
