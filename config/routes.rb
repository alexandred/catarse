require 'sidekiq/web'

Catarse::Application.routes.draw do
  match '/thank_you' => "static#thank_you"
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }
  check_user_admin = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin }

  filter :locale, exclude: /\/auth\//

  # Mountable engines
  constraints check_user_admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  mount CatarsePaypalExpress::Engine => "/", as: :catarse_paypal_express
  mount CatarseMoip::Engine => "/", as: :catarse_moip

  # Non production routes
  if Rails.env.development?
    resources :emails, only: [ :index ]
  end

  # Channels
  constraints subdomain: 'asas' do
    namespace :channels, path: '' do
      namespace :adm do
        resources :projects, only: [ :index, :update] do
          member do
            put 'approve'
            put 'reject'
            put 'push_to_draft'
          end
        end
      end
      get '/', to: 'profiles#show', as: :profile
      get '/how-it-works', to: 'profiles#how_it_works', as: :about
      resources :projects, only: [:new, :create, :show] do
        collection do
          get 'video'
          get 'check_slug'
        end
      end
      resources :channels_subscribers, only: [:index, :create, :destroy]
    end
  end

  # Static Pages
  get '/sitemap',               to: 'static#sitemap',             as: :sitemap
  get '/guidelines',            to: 'static#guidelines',          as: :guidelines
  get "/guidelines_tips",       to: "static#guidelines_tips",     as: :guidelines_tips
  get "/guidelines_backers",    to: "static#guidelines_backers",  as: :guidelines_backers
  get "/guidelines_project",    to: "static#guidelines_project",  as: :guidelines_start
  get "/guidelines_charity",    to: "static#guidelines_charity",  as: :guidelines_charity 
  get "/about",                 to: "static#about",               as: :about
  get '/faq',                   to: "static#faq",                 as: :faq
  get '/terms',                 to: "static#terms",               as: :terms
  get '/policy',                to: "static#policy",              as: :policy
  get '/contact',               to: "static#contact",             as: :contact
  get '/plans/redirect',        to: "plans#redirect",             as: :plansredirect
  get '/plans/redirect2',       to: "plans#redirect2",            as: :plansredirect2


  match "/explore" => "explore#index", as: :explore
  match "/explore#:quick" => "explore#index", as: :explore_quick
  match "/credits" => "credits#index", as: :credits

  match "/pages/paypal" => "paypal#paypal_ipn", :via => :post, as: :paypal
  match "/pages/paypal2" => "paypal#ipn2", :via => :post, as: :paypal2
  match "/pages/paypal3" => "paypal#ipn3", :via => :post, as: :paypal3

  match "/reward/:id" => "rewards#show", as: :reward
  resources :posts, only: [:index, :create]

  namespace :reports do
    resources :backer_reports_for_project_owners, only: [:index]
  end

  resources :projects do
    resources :updates, only: [ :index, :create, :destroy ]

    resources :donators, controller: 'projects/donators', only: [ :index, :new, :create ] do
      collection do
        get 'return'
      end
    end
    collection do
      get 'video'
      get 'check_slug'
    end
    member do
      put 'pay'
      get 'embed'
      get 'video_embed'
    end
  end

  resources :charities do
    resources :updates, only: [ :index, :create, :destroy ]

    resources :donations, controller: 'charities/donations', only: [ :index, :new, :create ] do
      collection do
        get 'return'
      end
    end

    collection do
      get 'video'
      get 'check_slug'
    end
    member do
      put 'pay'
      get 'embed'
      get 'video_embed'
    end
  end

  resources :plans
  
  resources :users do
    collection do
      get :uservoice_gadget
    end
    resources :backers, only: [:index] do
      member do
        match :request_refund
      end
    end

    resources :unsubscribes, only: [:create]
    member do
      get 'projects'
      get 'credits'
      put 'unsubscribe_update'
      put 'update_email'
      put 'update_password'
    end
  end
  # match "/users/:id/request_refund/:back_id" => 'users#request_refund'

  resources :credits, only: [:index] do
    collection do
      get 'buy'
      post 'refund'
    end
  end

  namespace :adm do
    resources :projects, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
      end
    end
    
    resources :charities, only: [ :index, :update, :destroy ] do
      member do
        put 'approve'
        put 'reject'
        put 'push_to_draft'
      end
    end

    resources :statistics, only: [ :index ]
    resources :financials, only: [ :index ]

    resources :backers, only: [ :index, :update ] do
      member do
        put 'confirm'
        put 'pendent'
        put 'change_reward'
        put 'refund'
        put 'hide'
        put 'cancel'
        put 'push_to_trash'
      end
    end
    resources :users, only: [ :index ]

    namespace :reports do
      resources :backer_reports, only: [ :index ]
    end
  end

  match "/mudancadelogin" => "users#set_email", as: :set_email_users
  match "/:permalink" => "projects#show", as: :project_by_slug
  match "/charities/:permalink" => "charities#show", as: :charity_by_slug
  match "/charities/search/:search" => "charities#search", as: :charity_search
  match "/charities/filter/recommended" => "charities#recommended"
  match "/charities/filter/nearby" => "charities#nearby"
  match "/charities/filter/:country" => "charities#country"

  # Root path
  root to: 'projects#index'
end
