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

    def self.find_or_create name
      User.all.select {|x| x.name == name}.first || User.new(name)
    end
  end

  class History
    attr_accessor :user_id, :completed_word, :errors, :did_win, :word
    @@store = []


    def initialize(user, game)
      @user_id = user.id
      @did_win = game.did_win?
      @errors = game.errors
      @word = game.word
      @completed_word = game.completed_word
      @@store << self
    end

    def all
      @@store
    end
  end

  class Dictionary
    def self.word
      return ["hello", "seek", "random"].sample
    end
  end

  class Game
    attr_accessor :word, :user_id, :errors, :possible_mistakes, :completed_word

    def initialize(user_id=nil)
      @word = Dictionary.word()
      @user_id = user_id
      @errors = []
      @possible_mistakes = 5
      @completed_word = "_"*self.word.length
    end

    def did_lose?
      @errors.length == @possible_mistakes
    end

    def did_win?
      self.completed_word == self.word
    end

    def guess
      puts @completed_word
      puts "Guess a letter? #{self.errors.length}/#{self.possible_mistakes} errors"
      response = gets.chomp
      self.check_response response
    end

    def check_response res
      # first check if valid response - needs to be "a...z" and only one letter
      if res.length != 1 || res.downcase <"a" || res.downcase > "z"
        puts "That is an invalid entry, please try again."
        return
      end
      if self.word.include?(res)
        # replace all letters
        @completed_word = @completed_word.split("").each_with_index.map{|x, i| word[i] == res ? res : x}.join("")
      else
        if @errors.include?(res)
          puts "You already gussed that. Try a different letter."
        else
          @errors << res.downcase
        end
      end
    end

  end

end

include Hangman

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
    History.new user, game
  end
  break if response == "N"
end
