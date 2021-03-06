Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :users, only: [:index, :show, :create, :update, :destroy]
  resources :roles, only: [:index]
  resources :posts, only: [:index, :show, :create, :update, :destroy]
end
