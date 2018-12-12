
# frozen_string_literal: true

# app/models/concerns/network_exception.rb
module NetworkException
  extend ActiveSupport::Concern

  SLEEP_INTERVAL = 0.4

  def with_retries(retries: 30, retry_skip_reason: nil, rescue_class: )
    tries = 0

    begin
      yield
    rescue *rescue_class => e
      tries += 1
      raise unless tries <= retries && (
        retry_skip_reason.nil? || !e.message.include?(retry_skip_reason)
      )
    end
  end

  private

  def sleep_interval(tries)
    (SLEEP_INTERVAL + rand(0.0..1.0)) * tries**2
  end
end
