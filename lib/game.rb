require 'set'
require_relative 'player'
require_relative 'aiplayer'

class Game

    attr_accessor :fragment, :current_player, :previous_player
    attr_reader :dictionary

    GHOST = ["G", "H", "O", "S", "T"]

    YESES = ["y", "yes", "yeah" "why not?" "sure", "go ahead"]

    DIFFICULTIES = ["easy", "medium", "hard"]
    
    def initialize
        # initialises everything to do with players
        @players = self.make_players
        @current_player = @players[0]
        @previous_player = @players[-1]

        # initialises everything to do with words
        @fragment = ''
        @dictionary = self.load_dictionary

        # initialises everything to do with the score
        @losses = self.losses
        @final_score = []
    end

    def make_players
        player_list = []

        # gets the number of all human players and their names
        puts "How many players are there?"
        num_players = gets.chomp.to_i
        (0...num_players).each do |i|
            puts "Player #{i + 1}, please enter your name:"
            player_list << Player.new(gets.chomp)
        end

        # once all humans are initialised, offer to let Hal play
        puts "Would you like to add an AI player?"
        if YESES.include?(gets.chomp.downcase)
            valid_difficulty = false
            while !valid_difficulty
                puts "What would you like to set the difficulty to?"
                puts "Pick easy, medium, or hard."
                difficulty = gets.chomp.downcase
                valid_difficulty = true if DIFFICULTIES.include?(difficulty)
            end
            player_list << AI_Player.new(difficulty)
        end

        # exits the game if only one person is playing
        if player_list.length < 2
            puts "You need at least two players for this game."
            exit(0)
        end

        player_list
    end

    def load_dictionary
        loaded = Set.new
        File.open("assets/dictionary.txt").each { |word| loaded << word.chomp }
        loaded
    end

    def play_round
        self.take_turn(@current_player)
        self.next_player!

        # if the previous round resulted in a completed word,
        # make sure all players and the score is up-to-date, and
        # reset the word
        if finished_word?(@previous_player)
            update_players(@previous_player)
            @fragment = ''
        end
    end

    def next_player!
        idx = (@players.index(@current_player) + 1) % @players.length
        @previous_player = @current_player
        @current_player = @players[idx]
    end

    def update_players(player)
        if @losses[player] == 5
            puts "#{player.name} is out of the game!"
            @players.delete(player)
            self.update_final_score(player)
        end
    end

    def take_turn(player)

        # AIs don't actually guess
        if player.is_a?(AI_Player)
            guess = player.make_move(@fragment, @players.length - 1, @dictionary)
        else
            guess = player.guess
        end

        while !self.valid_play?(guess)
            player.alert_invalid_guess
            guess = player.guess
        end

        @fragment += guess
    end

    def valid_play?(string)
        alphabet = ('a'..'z').to_a
        test = @fragment + string

        # checks that the player entered a letter and that there
        # are words that start with the fragment that would be created
        # by the player's move
        alphabet.include?(string) && dictionary.any? { |word| word.start_with?(test) }
    end

    def finished_word?(player)
        if @dictionary === @fragment
            puts "#{player.name} finished the word '#{@fragment}'!"
            @losses[player] += 1
            true
        else
            false
        end
    end

    def losses
        @losses = Hash.new(0)

        @players.each { |player| @losses[player] = 0 }

        @losses
    end

    def record(player)
        # converts the number of losses into a substring of "GHOST"
        if @losses[player] == 0
            substring = "#{player.name}: "
        else
            substring = "#{player.name}: #{GHOST[0...@losses[player]].join('')}"
        end
        substring
    end

    def run
        while @players.length != 1
            self.play_round
            self.display_standings if @players.length != 1
        end

        self.update_final_score(@current_player)
        self.display_final_score

        puts "#{@players[0].name} won the game!"
    end

    def display_standings
        puts "------"
        puts "CURRENT SCORE"
        @players.each { |player| puts self.record(player) }
        puts "------"
        puts "WORD: #{@fragment}"
        puts ''
    end

    def update_final_score(player)
        @final_score << player.name
    end

    def display_final_score
        puts "------"
        puts "FINAL SCORE"
        
        i = 0

        # starts from the end of the final_score array so that the
        # final score is printed as a list running from first to
        # last place
        while i < @final_score.length
            puts "#{i + 1}. #{@final_score[-(i + 1)]}"
            i += 1
        end
    end

end

if __FILE__ == $PROGRAM_NAME
    game = Game.new
    game.run
end