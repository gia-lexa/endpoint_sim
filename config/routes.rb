Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :files, only: [:create] do
        collection do
          patch 'update'  # Custom route-update does not use an id
          delete 'destroy' # Custom route-destroy does not use an id
        end
      end
      resources :logs, only: [:index] 
      resources :processes, only: [:create]
      resources :network, only: [:create]
    end
  end
end
