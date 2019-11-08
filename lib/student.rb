require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade
  attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
        );
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
      SQL
    
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    
    else  
      #inserts a new entry into the database
      sql_import = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
        SQL
    
      DB[:conn].execute(sql_import, self.name, self.grade)

      #assigns ID number from the database
      sql_extract = <<-SQL
        SELECT id FROM students
        ORDER BY id DESC LIMIT 1;
        SQL
    
      @id = DB[:conn].execute(sql_extract)[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET (name, grade) = (?, ?)
      WHERE id = ?;
      SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.new_from_db(student_data)
    #array contains, id, name, then grade
    new_student = Student.new(student_data[1], student_data[2], student_data[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ? LIMIT 1;
      SQL

    matched_student = DB[:conn].execute(sql, name)
    Student.new_from_db(matched_student[0])
  end

end
