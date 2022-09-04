class Dog
    attr_accessor :id, :name, :breed
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        query = <<-SQL
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(query)
    end

    def self.drop_table
        query = <<-SQL 
            DROP TABLE dogs
        SQL
        DB[:conn].execute(query)
    end

    def save             
        query = <<-SQL
            INSERT INTO dogs (              
                name,
                breed
            )
            VALUES (?,?)
        SQL
        DB[:conn].execute(query, name, breed)
        id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        # pp id
        self.id = id
        self       
    end

    def self.create(name:, breed:)
        query = <<-SQL
            INSERT INTO dogs (              
                name,
                breed
            )
            VALUES (?,?)
        SQL
        DB[:conn].execute(query, name, breed)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id IN (SELECT last_insert_rowid() FROM dogs)")[0]
        self.new(id: row[0], name: row[1], breed: row[2])  
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        query = <<-SQL
            SELECT * FROM dogs 
        SQL
       rows = DB[:conn].execute(query)
       rows.map { |row| self.new_from_db(row) }    
    end

    def self.find_by_name(name)
        query = <<-SQL
            SELECT * 
            FROM dogs 
            WHERE name = ?
            LIMIT 1
        SQL
        row = DB[:conn].execute(query, name)[0]
        self.new_from_db(row)
    end

    def self.find(id)
        query = <<-SQL
            SELECT * 
            FROM dogs 
            WHERE id = ?
            LIMIT 1
        SQL
        row = DB[:conn].execute(query, id)[0]
        self.new_from_db(row)
    end
end