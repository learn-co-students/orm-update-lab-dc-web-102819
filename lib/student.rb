require_relative "../config/environment.rb"

class Student

	attr_accessor :name, :grade, :id

	def initialize(name, grade, id=nil)
		@name = name
		@grade = grade
	end

	def self.create_table
		create  = <<-SQL
			CREATE TABLE IF NOT EXISTS students (
			id INTEGER PRIMARY KEY,
			name TEXT,
			grade INTEGER
			);
			SQL

		DB[:conn].execute(create)  	
	end

	def self.drop_table
		drop = <<-SQL
			DROP TABLE students;
			SQL

		DB[:conn].execute(drop)
	end

	def self.create(name, grade)
	  	student = Student.new(name, grade)
	  	student.save
	  	student
	end

	def save
		if self.id
			self.update
		else
			insert = <<-SQL
				INSERT INTO students (name, grade)
				VALUES (?,?)
				SQL

			DB[:conn].execute(insert, self.name, self.grade)

			@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
		end
	end

	def update
		sql = <<-SQL
			UPDATE students SET name = ?, grade = ?
			WHERE id = ?;
			SQL

		DB[:conn].execute(sql, self.name, self.grade, self.id)
	end

	def self.new_from_db(row)
		student = self.new(nil, nil)
		student.id = row[0]
		student.name = row[1]
		student.grade = row[2]
		student
	end

	def self.all
		sql = <<-SQL
			SELECT * FROM students;
			SQL

		DB[:conn].execute(sql).map do |row|
			self.new_from_db(row)
		end
	end

	def self.find_by_name(name)
		sql = <<-SQL
			SELECT * FROM students
			WHERE name = ?;
			SQL

		DB[:conn].execute(sql, name).map do |row|
			self.new_from_db(row)
		end.first
	end

end
