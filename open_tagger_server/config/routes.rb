# frozen_string_literal: true

Rails.application.routes.draw do
  resources :letters
  resources :collections
  resources :repositories
  # resources :property_labels
  # resources :entities
  # resources :places
  # resources :languages
  resources :literals
  resources :entity_types, path: 'entity-types'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # resources :people
  get '/search-entities', to: 'entities#search'
  resources :entities
end
