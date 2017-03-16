require_relative "../config/environment.rb"

class Student
  attr_accessor :grade, :name
  attr_reader :id

  def self.create(name, grade)
    new(name, grade).tap { |student| student.save }
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY, name VARCHAR(255), grade VARCHAR(255))")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT id, name, grade FROM students WHERE name = ?", name)[0].tap do |row|
      return new_from_db(row)
    end
  end

  def self.new_from_db(row)
    new(row[1], row[2], row[0])
  end

  def initialize(name, grade, id = nil)
    @grade = grade
    @id = id
    @name = name
  end

  def save
    if @id
      update
    else
      DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?, ?)", @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?", @name, @grade, @id)
  end
end
