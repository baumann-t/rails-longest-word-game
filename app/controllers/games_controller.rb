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
    @total_score = total_score(word_exist, letters_include_word, score)
  end

  def reset
    session.delete(:score)
    redirect_to '/'
  end

  private

  def word_exist?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    serialized = URI.open(url).read
    result = JSON.parse(serialized)
    result['found']
  end

  def letters_include_word?(word, letters)
    letters_array = letters.chars
    result = true
    word.chars.each do |l|
      if letters_array.include?(l)
        letters_array - [l]
      else
        result = false
      end
    end
    result
  end

  def game_result(word_exist, letters_include_word, user_input, letters)
    if word_exist && letters_include_word
      result = "CONGRATULATION! #{user_input} is an english word!"
    elsif !letters_include_word
      result = "Sorry, but #{user_input.capitalize} can't be build with #{letters.split('')}"
    elsif !word_exist
      result = "Sorry, but #{user_input.capitalize} doesn't seem to be an english word"
    end
    result
  end

  def total_score(word_exist, letters_include_word, score)
    if word_exist && letters_include_word
      if session[:score].nil?
        session[:score] = score
      else
        session[:score] += score
      end
    end
    session[:score] || 0
  end

end
