class Player

    attr_reader :name
    
    def initialize(name)
        @name = name
    end

    def guess
        puts "#{@name}'s turn"
        puts "Please enter a letter:"
        gets.chomp
    end

    def alert_invalid_guess
        puts "That guess was invalid."
    end

end