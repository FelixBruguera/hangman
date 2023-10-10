require 'json'

class Game
  attr_accessor :word, :word_array, :turn, :input, :incorrect, :old_game
  @@word = ""
  @@word_array = []
  @@input = ""
  @@turn = 10
  @@incorrect = []
  @@old_game = nil

  def self.save_game
    game_state = {'word': @@word,
      'word_array': @@word_array,
      'turn': @@turn,
      'incorrect': @@incorrect }
    date = Time.now.strftime('%d_%m_%y_%I_%M')
    File.open("saved_games/hangman_#{date}.json",'w') do |f|
    f.puts game_state.to_json
    end
  end
  
  def self.load_game
    files = {}
    Dir["saved_games/*"].each_with_index do |file,ind|
      files[ind] = file.to_s
    end
    files.each {|file| puts "#{file[0]} = #{file[1]}"}
    puts "Enter the number of the game you want to load"
    user_file = gets
    user_file = user_file.chomp.to_i
    unless files.keys.include?(user_file) 
      return puts "Wrong input" 
    end
    game_file = File.read(files[user_file])
    @@old_game = JSON.parse(game_file)
    Game.play('old')
  end
  
  def self.get_word
    words = File.open('lib/google-10000-english-no-swears.txt').readlines
    words = words.to_a.filter {|word| (5..12).include?(word.chomp.length)}
    @@word = words[rand(words.length)].chomp
    while @@word_array.length < @@word.length
      @@word_array.push("_ ")
    end
  end

  def check_guess
    @@word.split("").to_a.each_with_index do |letter,ind|
      if letter == @@input then @@word_array[ind] = "#{@@input} " end
    end
    if @@input.length == 1
      unless @@word.include?(@@input) || @@incorrect.include?(@@input)
        @@turn -= 1
        @@incorrect.push(@@input)
      end
    end
  end

  def check_game
    if @@input == @@word || @@word_array.none? {|word| word == '_ '}
      return 'You win!'
    end
    if @@turn == 0
      return "You lose, the word was #{@@word}"
    end
  end
  
  def check_word(word)
    if @@input == 'save_game' then return Game.save_game end
    if @@input == 'load_game' then return "" end
    if @@word != word then 
      puts "That's not the word" 
      @@turn -=1
    end
  end
  
  def self.play(type='new')
    player = User.new
    if type == 'new'
      puts "You have 10 chances to guess the word"
      puts "You can enter a letter or the whole word"
      puts "To save the game enter 'save_game'"
      puts "To load one of your saved games, enter 'load_game'"
      self.get_word
    end
    if type == 'old'
      @@word = @@old_game['word']
      @@word_array = @@old_game['word_array']
      @@turn = @@old_game['turn']
      @@incorrect = @@old_game['incorrect']
      puts "You have #{10-@@turn} guesses left"
    end
    while @@turn > 0
      player.user_input
      if @@input == 'save_game' then return puts "Game saved" end
      if @@input == 'load_game' then return Game.load_game end
      player.check_guess
      check = player.check_game
      if check != nil
        puts @@word
        return puts check
      end
    end
  end
end

class User < Game
  
  def user_input
    puts "Guesses left: #{@@turn}"
    puts @@word_array.join(" ")
    puts "Incorrect guesses: #{@@incorrect.join(",")}"
    input = gets
    input = input.chomp.downcase
    if input.length == 1 && ('a'..'z').include?(input)
      @@input = input
    elsif input.length > 1
     if input.each_char {|word| ('a'..'z').include?(word)}
      @@input = input
      check_word(input)
     else
      return puts "Wrong input"
     end
    else
      return puts "Wrong input"
    end
  end
end

Game.play