require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    alphabet = ('a'..'z').to_a
    @letters = []
    9.times { @letters.push(alphabet.sample) }
  end

  def score
    letters = params[:letters]
    user_input = params[:word_choice]

    word_exist = word_exist?(user_input)
    letters_include_word = letters_include_word?(user_input, letters)

    @result = game_result(word_exist, letters_include_word, user_input, letters)

    score = user_input.length if word_exist && letters_include_word
    @total_score = total_score(score)
  end

  def reset
    session.delete(:score)
    redirect_to '/'
  end

  private

  def word_exist?(word)
    JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{word}").read)['found']
  end

  def letters_include_word?(word, letters)
    select_letters = word.chars.select{ |l| letters.chars.include?(l) }
    return true if select_letters.length == word.length
  end

  def game_result(word_exist, letters_include_word, user_input, letters)
    return "CONGRATULATION! #{user_input} is an english word!" if word_exist && letters_include_word
    return "Sorry, but #{user_input.capitalize} can't be build with #{letters.split('')}" if !letters_include_word
    return "Sorry, but #{user_input.capitalize} doesn't seem to be an english word" if !word_exist
  end

  def total_score(score)
    session[:score].nil? ? session[:score] = score : session[:score] += (score || 0)
  end
end
