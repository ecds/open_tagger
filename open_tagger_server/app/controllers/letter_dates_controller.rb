# frozen_string_literal: true

# app/controllers/letters_controller.rb
class LetterDatesController < ApplicationController
  def index
    if ['http://ot.ecdsdev.org', 'http://localhost:4200'].include? request.headers['HTTP_ORIGIN']
      @letters = Letter.all
    else
      @letters = Letter._public
    end
    render json: {
      data: [
        id: '42',
        type: 'letter-dates',
        attributes: {
          min: @letters.minimum('date'),
          max: @letters.maximum('date')
        }
      ]
    }
  end
end
