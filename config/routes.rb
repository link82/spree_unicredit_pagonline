Rails.application.routes.draw do

  get 'unicredit_pagonline/listener', to: 'spree/unicredit_pagonline#listener', as: :unicredit_pagonline_listener
  get 'unicredit_pagonline/show', to: 'spree/unicredit_pagonline#show', as: :unicredit_pagonline_show
  post 'unicredit_pagonline/ok', to: 'spree/unicredit_pagonline#result_ok', as: :unicredit_pagonline_ok
  post 'unicredit_pagonline/ko', to: 'spree/unicredit_pagonline#result_ko', as: :unicredit_pagonline_ko

end
