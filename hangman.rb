#!/usr/bin/env ruby

module Hangman
  class User
    attr_accessor :name, :id
    @@store = []

    def initialize(name = nil)
      @name = name
      @id = @@store.length
      @@store << self
    end


    def self.all
      @@store
    end

    def histories
      History.all.select{|x| user_id === self.id}
    end

    def find_or_create name
      User.all.select {|x| x.name == name}.first || User.new name
    end
  end

  class History
    attr_accessor :user_id, :guesses, :errors, :did_win, :word
    @@store = []


    def initialize(user_id = nil, guesses= nil, errors = nil, word = nil, did_win = nil)
      @user_id = user_id
      @did_win = did_win
      @errors = errors
      @word = word
      @guesses = guesses
      @@store << self
    end

    def all
      @@store
    end
  end

  class Dictionary
    def initialize
      return ["Hello", "Seek", "Random"].sample
    end
  end

  class Game
    attr_accessor :word, :user_id, :errors, :possible_mistakes, :completed_word

    def initialize(user_id=nil)
      @word = Dictionary.new
      @user_id = user_id
      @errors = []
      @possible_mistakes = 5
      @completed_word = "_"*@word.length
    end

    def did_lose?
      @errors.length == @possible_mistakes
    end

    def did_win?
      self.completed_word == self.word
    end

    def guess
      puts @completed_word
      puts "Guess a letter?"
      response = gets.chomp
      self.check_response response
    end

    def check_response res
      # first check if valid response - needs to be "a...z" and only one letter
      if res.length != 1 || res.downcase <"a" || res.downcase > "z"
        "That is an invalid entry, please try again."
        return
      end
      if self.word.include?(res)
        # replace all letters
        @completed_word = @completed_word.split("").each_with_index.map{|x, i| word[i] == res ? res : x}.join("")
      else
        @errors << res.downcase
      end
    end

  end

end

puts "What is your name?"
name = gets.chomp
user = User.find_or_create name
loop do
  puts "Would you like to play hangman (Y/N)"
  response = gets.chomp
  puts "I'm sorry I didn't get that." if !["Y","N"].include?(response)
  if response == "Y"
    game = Game.new
    while !game.did_win? && !game.did_lose?
      game.guess
    end
    if game.did_win?
      puts "Congrats you won!"
    else
      puts "Sorry you lost. Maybe next time."
    end
  end
  break if response == "N"
end
