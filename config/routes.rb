# frozen_string_literal: true

# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  # activeadmin authenticates users, who must be in a certain 'group' (our concept)
  #
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # users don't log in to a conventional website; they only access the site via the API without auth
  #
  # devise_for :admin_users, { class_name: 'User' }.merge(ActiveAdmin::Devise.config)
  # ActiveAdmin.routes(self)
  # devise_for :users

  root to: 'home#index'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get 'service-worker' => 'rails/pwa#service_worker', as: :pwa_service_worker
  get 'manifest' => 'rails/pwa#manifest', as: :pwa_manifest

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create show index] do
        collection do
          post 'verify', action: :verify
          get 'get_reputation', action: :get_reputation
          get 'ping', action: :ping
          get 'ping_auth', action: :ping_auth
        end
      end
      resources :elections, only: %i[] do
        collection do
          get 'list_open_elections', action: :list_open_elections
          post 'vote_in_election', action: :vote_in_election
        end
      end

      resources :memberships, only: %i[index]

      resources :payments, only: %i[] do
        collection do
          post 'create_subscription', action: :create_subscription
        end
      end

      devise_scope :user do
        post 'sign_in', to: 'sessions#create'
        post 'sign_out', to: 'sessions#delete'

        get 'ping', to: 'sessions#ping'
      end
    end
  end
end
