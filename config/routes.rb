Rails.application.routes.draw do

  devise_for :staffs,controllers:{
  	sessions: 'staffs/sessions'
  }
  devise_for :owners,controllers:{
  	sessions: 'owners/sessions'
  }

  root :to => "tops#about"

  concern :today do
	  resources :todays, only:[:new,:creat,:index,:edit,:update,:destroy]
	  get 'todays/thanks' => "todays#thanks"
  end

  concern :payment do
	  resources :payments, only:[:index,:new,:creat]
  end

  concern :today_grade do
	  resources :today_grades, only:[:index],concerns: :payment
	  get 'todays/finish' => "todays_grades#finish"
	  get 'todays/confirm' => "todays_grades#confirm"
  end

  concern :order do
	  resources :orders, only:[:new,:creat]
  end

  concern :table do
	  resources :tables, only:[:new,:creat,:show,:edit,:update],concerns: :order
	  get 'tables/:id/add' => "tables#add"
	  patch 'tables/:id/add' => "tables#adding"
	  get 'tables/:id/extention' => "tables#extention"
	  patch 'tables/:id/extention' => "tables#extentioning"
	  get 'tables/:id/special' => "tables#special"
	  patch 'tables/:id/special' => "tables#specialing"
  end

  concern :mounth_grade do
  	resources :mounth_grades, only:[:index], concerns: :today_grade
  end

  concern :staff do
  	resources :staffs, only:[:index,:creat,:edit,:update]
  end

  concern :product do
  	resources :products, only:[:index,:new,:creat,:destroy]
  end

  concern :girl do
  	resources :girls, only:[:index,:creat,:edit,:show,:update,:destroy]
  end

  concern :accounting do
	  resources :accountings, only:[:new,:creat,:edit,:update,:confirm]
  end

  resources :shops, only:[:index,:new,:creat,:show,:edit,:update,:destroy],concerns: [:accounting, :girl, :product, :staff, :today, :mounth_grade, :table]
  get 'shops/add' => "shops#add"
  post 'shops/add' => "shops#adding"
  get 'shop/:id/top' => "shops#top"
  get 'shop/:id/rall' => "shops#rall"
  patch 'shop/:id/ralling' => "shops#ralling"
  get 'shop/:id/detial' => "shops#detial"
  patch 'shop/:id/detial' => "shops#setting"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
