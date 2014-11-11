require 'jersey'
Jersey.setup

class API < Jersey::API::Base
  get '/hello' do
    Jersey.log(at: "hello")
    'hello'
  end

  get '/not_found' do
    raise NotFound, "y u no here?"
  end
end

run API
