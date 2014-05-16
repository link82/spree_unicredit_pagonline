Rails.application.routes.draw do

  get 'unicredit_pagonline/eventlistener', to: 'spree/unicredit_pagonline#eventlistener', as: :unicredit_pagonline_eventlistener
  get 'unicredit_pagonline/show/:order_id/:payment_method_id', to: 'spree/unicredit_pagonline#show', as: :unicredit_pagonline_show
  get 'unicredit_pagonline/ok', to: 'spree/unicredit_pagonline#result_ok', as: :unicredit_pagonline_ok
  get 'unicredit_pagonline/ko', to: 'spree/unicredit_pagonline#result_ko', as: :unicredit_pagonline_ko

end
