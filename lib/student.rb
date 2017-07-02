require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name,grade,id=nil)
    @name  = name
    @grade = grade
    @id    = id
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students
    (id INTEGER PRIMARY KEY,
     name TEXT,
     grade INTEGER
    );"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def save
    if @id
      update
    else
      sql = "INSERT INTO students VALUES(?,?,?);"
      if @id.nil?
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")#[0][0]
        if @id[0].nil?
          @id = 1
        else
          @id = @id[0][0]
        end
      end
      DB[:conn].execute(sql,@id,@name,@grade)
    end
  end

  def update
    sql = "UPDATE students SET id = ?, name = ?, grade = ?"
    DB[:conn].execute(sql,@id,@name,@grade)
  end

  def self.create(name,grade)
    student = Student.new(name,grade)
    student.save
    student
  end

  def self.new_from_db(row)
    id    = row[0]
    name  = row[1]
    grade = row[2]
    student = Student.new(name,grade,id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    rows = DB[:conn].execute(sql,name)
    Student.new_from_db(rows[0])
  end
end
