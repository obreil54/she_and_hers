Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [:show]

  resources :products, only: [:index, :show, :new, :create]

  resources :carts, only: [:show] do
    patch :update_item_quantity, on: :member
    delete :remove_item, on: :member
    post :add_item, on: :member
  end

  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'
  get 'faq', to: 'pages#faq'
  get 'explore', to: 'pages#explore'
  get 'privacy', to: 'pages#privacy'
  get 'terms', to: 'pages#terms'
end
