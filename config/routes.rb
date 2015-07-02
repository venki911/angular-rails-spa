Rails.application.routes.draw do

  get 'api_tokens/create'

  root 'site#index'

  get '/signup', to: 'stores#new', as: 'signup'
  get '/login', to: 'sessions#new', as: 'login'
  post '/sessions', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy', as: 'logout'

  post '/stores', to: 'stores#create'

  get '/account/:id', to: 'stores#show', as: 'account'

end
