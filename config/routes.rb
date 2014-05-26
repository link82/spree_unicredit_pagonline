Rails.application.routes.draw do

  post 'unicredit_pagonline/eventlistener', to: 'spree/unicredit_pagonline#eventlistener', as: :unicredit_pagonline_eventlistener
  get 'unicredit_pagonline/show', to: 'spree/unicredit_pagonline#show', as: :unicredit_pagonline_show
  post 'unicredit_pagonline/ok', to: 'spree/unicredit_pagonline#result_ok', as: :unicredit_pagonline_ok
  post 'unicredit_pagonline/ko', to: 'spree/unicredit_pagonline#result_ko', as: :unicredit_pagonline_ko

end
