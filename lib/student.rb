require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY, name TEXT, grade INTEGER);")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students;")
  end

  def save
    if @id
      update
    else
      sql = <<-SQL
      INSERT INTO students(name, grade)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, [@name, @grade])
      sql = "SELECT last_insert_rowid() FROM students;"
      @id = DB[:conn].execute(sql)[0][0]
    end
  end

  def self.create(name, grade)
    new(name, grade).tap{|o| o.save}
  end

  def self.new_from_db(row)
    new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?;"
    DB[:conn].execute(sql, name).collect do |row|
      new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?;
    SQL
    DB[:conn].execute(sql, [@name, @grade, @id])
    self
  end
end
