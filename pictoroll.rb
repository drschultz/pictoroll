require 'rubygems'
require 'sinatra'
require 'haml'
require 'lib/model'

get '/' do
  'Hi!'
end

get '/image/:id' do 
  response['Content-Type'] = 'image/jpeg'
  Post.select(:image_binary).where('id = ?', [params[:id]]).single_value.unpack('m')
end