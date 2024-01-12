Rails.application.routes.draw do
  root 'user_details#new'
  # devise_for :users, controllers: {
  #   registrations: 'users/registrations'
  # }
  resources :user_details, only: [:new, :create, :show]
end
