require 'api_constraints'

Rails.application.routes.draw do

  constraints subdomain: 'admin' do
    scope module: 'admin', as: 'admin' do
      DashboardManifest::DASHBOARDS.each do |dashboard_resource|
        resources dashboard_resource
      end

      resources :updates do
        member do
          post :accept
          post :reject
        end
      end

      resources :klubs do
        member do
          post :toggleverify
          post :send_data_verification_email
        end
      end

      root controller: DashboardManifest::ROOT_DASHBOARD, action: :index, as: :admin
    end
  end

  get '/rails/mailers' => "rails/mailers#index"
  get '/rails/mailers/*path' => "rails/mailers#preview"

  constraints subdomain: 'api' do
    scope module: 'api' do
      scope module: :v2, constraints: ApiConstraints.new(version: 2, default: true) do
        resources :obcinas, only: [:show]
        resources :comments, only: [:create]
        resources :comment_requests, only: [:create], :path => '/comment-requests'
        resources :klubs, only: [:index, :create, :update, :show] do
          member do
            get :images
            post :confirm
          end
        end
        resources :online_training_entries, only: [:index]
        post 'email_stats/webhook' => 'email_stats#webhook'
      end
    end
  end

  constraints subdomain: ['', 'www'] do

    get '/heartbeat' => 'application#heartbeat'

    get '/sitemaps/sitemap.xml.gz' => 'application#sitemap'

    root 'application#index'

    get '*path' => 'application#index'
  end
  # constraints subdomain: 'import' do
  #   post 'klubs/create'
  #   # resources :klubs, only: [:create]
  # end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
