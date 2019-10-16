class AI_Player

    attr_reader :name

    def initialize(difficulty)
        @name = "Hal"
        @difficulty = self.set_difficulty(difficulty)
        @previous_starting_letters = []
    end

    def set_difficulty(difficulty)
        # difficulty affects how many moves ahead Hal looks
        # when analysing moves
        if difficulty == "easy"
            @difficulty = 3
        elsif difficulty == "medium"
            @difficulty = 5
        elsif difficulty == "hard"
            @difficulty = 7
        end
    end

    def make_move(fragment, num_other_players, dictionary)
        puts "#{@name}'s turn"
        
        possibilities = self.analyse_moves(fragment, num_other_players, dictionary)

        if possibilities.is_a?(Hash)
            # if there are good moves available, Hal has a 50/50
            # chance of picking the best move or of picking a random
            # move out of the selection of good moves. this is in the
            # interest of making gameplay more varied
            if rand(2) == 0
                possibilities.each do |letter, quality|
                    if quality == possibilities.values.max
                        self.store_starting_letters(letter, fragment)
                        letter
                    end
                end
            else
                letter = possibilities.keys[rand(0...possibilities.keys.length)]
                self.store_starting_letters(letter, fragment)
                letter
            end
        else
            # if there are only losing moves available, Hal will
            # pick one at random
            possibilities[rand(0...possibilities.length)]
        end
    end

    def analyse_moves(fragment, num_other_players, dictionary)
        alphabet = ('a'..'z').to_a

        # if Hal is starting the word, he can't pick the same
        # letter every time. this removes recently-picked
        # starting characters from his choices
        self.dont_repeat_yourself(alphabet) if fragment == ''

        guesses = {}
        losing_guesses = []

        alphabet.each do |letter|
            test = fragment + letter
            if dictionary === test
                losing_guesses << letter
            elsif in_dictionary?(test, dictionary)
                words = self.future_moves(test, dictionary)
                guesses[letter] = self.check_future_moves(words, fragment.length, num_other_players)
            end
        end

        # if there are good moves, return those. otherwise,
        # return losing moves
        self.return_best_moves(guesses, losing_guesses)
    end

    def return_best_moves(guesses, losing_guesses)
        if !guesses.empty?
            guesses
        else
            losing_guesses
        end
    end

    def future_moves(fragment, dictionary)
        # collects words that start with the fragment already spelled
        words = dictionary.select { |word| word.start_with?(fragment) }
    end

    def check_future_moves(words, fragment_length, num_other_players)
        # how many moves ahead Hal looks
        moves_ahead = (1..@difficulty).to_a

        move_quality = 0

        moves_ahead.each do |move|
            # Hal favours words that end on someone else's turn
            ideal_length = fragment_length + (num_other_players * move)

            words.each do |word| 
                if word.length <= ideal_length
                    move_quality += 1
                elsif word.length == ideal_length + 1
                    move_quality -= 1
                end
            end
        end

        move_quality
    end

    def in_dictionary?(fragment, dictionary)
        dictionary.any? { |word| word.start_with?(fragment) }
    end

    def dont_repeat_yourself(alphabet)
        # the previous_starting_letters array should only hold a set number
        # of letters, so that Hal can eventually start words with previously
        # used letters again. currently hard-coded at 3, could potentially
        # be tied to a more nuanced difficulty scale
        @previous_starting_letters.delete_at(0) if @previous_starting_letters.length > 3

        # removes letters in array from the set of moves Hal will analyse
        @previous_starting_letters.each { |letter| alphabet.delete(letter) }
        alphabet
    end

    def store_starting_letters(letter, fragment)
        # stores letter chosen if Hal is starting a word
        @previous_starting_letters << letter if fragment == ''
    end

end