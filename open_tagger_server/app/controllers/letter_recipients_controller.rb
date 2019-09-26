# frozen_string_literal: true

# app/controllers/letters_controller.rb
class LetterRecipientsController < ApplicationController
  def index
    if ['http://ot.ecdsdev.org', 'http://localhost:4200'].exclude? request.headers['HTTP_ORIGIN']
      @recipients = []
      Letter._public.collect(&:recipients).uniq.each { |r| r.map{ |e| @recipients.append(id: e.id, recipient: e.label, count: e.letters_written_to_person.count) } }
    else
      @recipients = LetterRecipient.all
                                   .collect(&:entity)
                                   .uniq
                                   .map { |e| { recipient: e.label } }
    end
    render json: @recipients
  end
end
