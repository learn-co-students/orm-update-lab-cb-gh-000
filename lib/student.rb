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
		DB[:conn].execute('CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY, name TEXT, grade TEXT)')
	end
 
	def self.drop_table
		DB[:conn].execute("DROP TABLE students")
	end

	def save
		if self.id
			self.update
		else
			DB[:conn].execute('INSERT INTO students (name, grade) VALUES (?, ?)', self.name, self.grade)
			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
		end
	end
 
	def self.create(name, grade)
		self.new(name, grade).tap { |student| student.save }
	end
 
	def self.new_from_db(row)
		self.new(row[1], row[2], row[0])
	end
 
	def self.find_by_name(name)
		DB[:conn].execute('SELECT id, name, grade FROM students WHERE name=?', name)[0].tap do |row|
			return self.new_from_db(row)
		end
	end

	def update
		DB[:conn].execute('UPDATE students SET name=?, grade=? WHERE id=?', @name, @grade, @id)
	end

end
