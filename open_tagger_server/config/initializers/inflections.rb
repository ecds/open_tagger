# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.plural(/^(music)$/i, '\1')
  inflect.plural(/^(translat)ing$/i, '\1ions')
  inflect.plural(/^(work)(.*)(art)$/i, '\1s\2\3')
  inflect.plural(/^(attendance)$/i, '\1')
end