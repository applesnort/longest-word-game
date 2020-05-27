require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def timestamp
    Time.new.to_i
  end
  
  def new
    @start_time = timestamp
    @letters = generate_grid(10)
  end

  def score
    @end_time = timestamp
    @start_time = params[:start_time].to_i
    # binding.pry
    @guess = params[:answer]
    @grid = params[:letters]
    @run_game = run_game(@guess, @grid, @start_time, @end_time)
  end

  # let's do this

  def generate_grid(grid_size)
    # Array.new(grid_size) { ('A'..'Z').to_a.sample }
    alphabet = ("A".."Z").to_a
    "AAAEEEEIIOOOUU".chars.each { |letter| alphabet << letter }
    return alphabet.sample(10)
  end
  
  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end
  
  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end
  
  def run_game(attempt, grid, start_time, end_time)
    result = { time: end_time - start_time }
  
    score_and_message = score_and_message(attempt, grid, result[:time])
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
  
    result
  end
  
  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end
  
  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end  
end
