require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.sample(10)
    @start_time = Time.now.hour * 3600 + Time.now.min * 60 + Time.now.sec
  end

  def score
    end_time = Time.now.hour * 3600 + Time.now.min * 60 + Time.now.sec
    @grid = params['letters']
    @attempt = params['attempt']
    @time = end_time - params['start_time'].to_i

    score_and_message = score_and_message(@attempt, @grid, @time)
    @score = score_and_message.first.round(3)
    @message = score_and_message.last
  end

  private

  def included?(attempt, letters)
    attempt.chars.all? { |letter| attempt.count(letter) <= letters.count(letter) }
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def compute_score(attempt, time_taken)
    time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, grid, time)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        score = compute_score(attempt, time)
        [score, 'well done']
      else
        [0, 'not an english word']
      end
    else
      [0, 'not in the grid']
    end
  end
end
