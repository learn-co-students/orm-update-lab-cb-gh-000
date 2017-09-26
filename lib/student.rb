require_relative "../config/environment.rb"

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
    attr_accessor :name, :grade, :id

    def initialize(name, grade)
        @name, @grade = name, grade
        @id = nil
    end

    def self.create_table
        sql = 'CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)'
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = 'DROP TABLE students'
        DB[:conn].execute(sql)
    end

    def save
        if @id == nil
            sql = 'INSERT INTO students (name, grade) VALUES (?, ?)'
            DB[:conn].execute(sql, self.name, self.grade)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
        else
            sql = 'UPDATE students SET name=?, grade=? WHERE id=?'
            DB[:conn].execute(sql, self.name, self.grade, self.id)
        end
    end

    def self.create(name, grade)
        student = self.new(name, grade)
        student.save
        student
    end

    def self.new_from_db(row)
        student = self.new(row[1], row[2])
        student.id = row[0]
        student
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
        row = DB[:conn].execute(sql, name).flatten

        student = self.new_from_db(row)
        student
    end

    def update
        self.save
    end
end
