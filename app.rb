require 'dotenv/load'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'warden'
require 'rack-flash'
require './models/user.rb'
require 'colorize'

enable :sessions
set :sessions, session_store: Rack::Session::Cookie,
               key: 'sinatra_auth.session',
               expire_after: (60 * 60 * 24 * 365),
               secret: ENV['SESSION_SECRET']

use Rack::Flash

use Warden::Manager do |config|
  config.serialize_into_session(&:id)
  config.serialize_from_session { |id| User.find(id) }
  config.scope_defaults :default, strategies: [:password], action: '/unauthenticated'
  config.failure_app = Sinatra::Application
end

Warden::Strategies.add(:password) do
  def valid?
    puts '(Warden::Strategies) valid?'.colorize(:blue)
    params['username'] && params['password']
  end

  def authenticate!
    puts '(Warden::Strategies) authenticate!'.colorize(:blue)
    user = User.find_by(username: params['username'])

    if user&.authenticate(params['password'])
      puts '(Warden::Strategies) user present and authenticate returns true'.colorize(:green)
      success!(user)
    else
      puts '(Warden::Strategies) could not authenticate'.colorize(:red)
      fail!('Could not log in')
    end
  end
end

Warden::Manager.before_failure do |env, _opts|
  env['REQUEST_METHOD'] = 'POST'
end

helpers do
  def authenticated?
    env['warden'].user.present?
  end

  def signup_enabled?
    eval(ENV['SIGNUP_ENABLED'])
  end

  def check_signup_enabled
    unless signup_enabled?
      flash[:error] = 'Sign up disabled'
      redirect '/signin'
    end
  end

  def flash_message_classes(name)
    classes = 'rounded-lg p-6 mb-6 mx-4 '
    classes += 'bg-red-200 text-red-900' if name == 'error'
    classes += 'bg-green-200 text-green-900' if name == 'success'
    classes
  end
end

before do
  @current_user = env['warden'].user
end

get '/' do
  if authenticated?
    send_file('static/index.html')
  else
    erb :index
  end
end

get '/signin' do
  erb :signin
end

get '/signup' do
  check_signup_enabled

  erb :signup
end

post '/signin' do
  env['warden'].authenticate!
  flash[:success] = 'Logged in!'

  redirect_to = session[:return_to] || '/static/index.html'
  puts "logged in, redirect to #{redirect_to}".colorize(:green)

  redirect(redirect_to)
end

post '/signup' do
  check_signup_enabled

  user = User.new(username: params['username'], password: params['password'])
  if user.save
    env['warden'].authenticate!
    flash[:success] = 'Logged in!'

    redirect_to = session[:return_to] || '/static/index.html'
    puts "logged in, redirect to #{redirect_to}".colorize(:green)
  else
    flash[:error] = 'Username not created'
    redirect_to = '/signup'
  end

  redirect(redirect_to)
end

get '/logout' do
  env['warden'].logout

  flash[:success] = 'Successfully logged out'
  redirect '/'
end

post '/unauthenticated' do
  puts 'POST /unauthenticated'.colorize(:red)
  session[:return_to] = env['warden.options'][:attempted_path]

  flash[:error] = env['warden'].message || 'Please sign in with correct username and password'
  redirect '/signin'
end

get '/*' do
  env['warden'].authenticate!

  fname = params[:splat][0]
  path = File.join('static', fname.to_s)

  if Dir.exist?(path)
    return send_file(path + '/index.html')
  elsif File.exist?(path)
    return send_file(path)
  end

  status 404
  erb :not_found
end
