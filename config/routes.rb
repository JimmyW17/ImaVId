Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'home#index'
  # get '/uploads' => 'uploads#get_tags'
  resources :uploads
  resources :album do
    resources :pictures
  end
  root to: 'home#index'
end
