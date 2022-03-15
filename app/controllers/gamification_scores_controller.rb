# frozen_string_literal: true

class DiscourseGamification::GamificationScoresController < ApplicationController

  def index
    puts "hello"
    puts "hello"
    puts "hello"
    puts "hello"
    respond_to do |format|
      format.js {
        "1"   
      }
      format.html
    end
  end
end
