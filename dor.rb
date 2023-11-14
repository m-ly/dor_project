require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader"
require "sinatra/json"
require "tilt/erubis"
require "date"
require 'securerandom'
require 'redcarpet'
require 'bcrypt'
require 'pry'

require_relative 'data/persistence'

configure do
  enable :sessions
  set "session_secret", SecureRandom.hex(32)
end

configure do #(:development)
  require 'sinatra/reloader'
  also_reload 'data/persistence.rb'
end

before do
  @storage = DatabasePersistence.new(logger)
  session[:users] = {admin: @admin ||[], trainers: @trainers || [] , trainees: @trainees || []}
  @admin = @storage.select_users('is_admin')
  @trainers = @storage.select_users('is_trainer')
  @trainees = @storage.select_users('is_trainee')
  @date = DateTime.now.strftime("%m-%d-%Y")
end

# convienence functions
def any_string_vals_in_params(*url_params)
  url_params.any? do |param|
    next if param.nil?

    param.match(/^[1-9]\d*$/).nil?
  end
end

def create_new_user(first_name, last_name, email, password, type)
  hashed_password = BCrypt::Password.create(password)
  user_type = params[:user_type]

  @storage.create_user(first_name, last_name, email, hashed_password, type)
  session[:first_name] = first_name
  session[:user_id] = @storage.find_user_id(email)
  session[:message] = "User Created! You're logged in as #{first_name}, #{last_name}"
  redirect '/'
end

def load_form(index)
  form = session[:forms][index] if index <= session[:forms].size
  return form if form

  session[:error] = "That form does not exist"
  redirect  "/forms"
end

def valid_user_credentials?(username, password)
  if load_user(username)
    session[:message] = "Username: #{username} is already taken"
    redirect "/signup?username=#{username}"
  end

  valid_username?(username) && valid_password?(password)
end

def valid_password?(password)
  password.match?(/^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*\W).{8,}$/)
end

def save_blank_form(form)

end

get "/" do

  erb :index, layout: :layout
end

get "/admin" do
  erb :admin, layout: :layout
end

post "/assign" do
  @assigned =[ params[:trainer_name], params[:trainee_name]]
  redirect "/admin"
  erb :admin, layout: :layout
end

### Template Functions ###

get "/forms/create" do
  erb :create, layout: :layout
end

post "/forms/create" do
  data = JSON.parse(request.body.read)
  @storage.create_template(data, DateTime.now(), DateTime.now(), 15)
  redirect '/forms'
end

post "/forms/:form_id/delete/:item_id" do
  form_id = params[:form_id].to_i
  item_id = params[:item_id].to_i

  current_form = ''
  current_form[:criteria].delete_at(item_id)

  redirect "/forms/#{form_id}/edit"
end

post "/forms/:form_id/delete" do
  print params[:form_id]
  form_id = @storage.delete_template(params[:form_id])
  redirect "/forms"
end

get "/forms" do
  @templates = @storage.load_templates
  @evaluations = @storage.load_evals
  erb :forms, layout: :layout
end

# Generic Form View

get "/forms/:form_id" do
  @form_id = params[:form_id].to_i

  @data = @storage.load_template(@form_id)
  @form_name = @data.first['title']

  erb :view_form, layout: :layout
end


# Form Template Creation and Editing

get "/forms/:form_id/edit" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)

  @form_name = form[:document_name]
  @criteria = form[:criteria]

  erb :form_edit,layout: :layout
end




### Evaluation Functions ###

post '/evals/:template_id/save' do
  data = JSON.parse(request.body.read).to_h
  trainee_id = data.delete('traineeId')
  template_id = params[:template_id]
  title = trainee_id + @date

  eval_id = @storage.create_eval( title, session[:user_id], trainee_id, template_id, DateTime.now)


  data.each do |criteria_id, sub_h|
    text_content = nil
    number_ranking = nil
    sub_h.to_h.each do |heading, value|
      if value.to_i != 0
        number_ranking = value
      else
        text_content = value
      end
    end

    @storage.save_eval(eval_id, criteria_id, number_ranking, text_content)
   end

   session[:message] = "Sucessfully Saved!."
   redirect "/forms"
end

# Forms Attributed to a Trainee




# User Views

# Signup Form
post '/users/new' do
  first_name = params[:first_name].strip
  last_name = params[:last_name].strip
  email = params[:email].strip
  password = params[:password].strip
  user_type = params[:user_type]

  #if valid_user_credentials?(username, password) && password == params[:verify_password]
  if first_name && last_name && email && password
    create_new_user(first_name, last_name, email, password, user_type)
  else
    session[:message] = 'Please check for errors and, please try again'
    redirect "/users/new=#{email}"
  end
end

get '/login' do
  erb :login, layout: :layout
end


post '/login' do
  email = params[:email].strip
  password = params[:password].strip

  url = session[:url] || '/'
  user_data = @storage.load_user_data(email)

  if user_data && BCrypt::Password.new(user_data[:password]) == password
    session[:message] = "Welcome Back! #{user_data[:first_name]} #{user_data[:last_name]}. Redirecting to #{url}."
    session[:user_id] = user_data[:user_id]
    redirect url
  else
    status 401
    session[:message] = 'Invalid username or password combination'
    redirect "/login?username=#{email}"
  end
end

# Clear session data / logout user
get '/logout' do
  session.clear
  session[:message] = 'You have be logged out.'
  redirect '/home'
end

get "/trainees" do
  @trainees = @storage.select_users('is_trainee')
  erb :trainees, layout: :layout
end

post "/trainees/new" do
  session[:trainees] << params[:add_trainee]
  redirect "/trainees"
end

get "/trainers" do
  @trainers =  @storage.select_users('is_trainer') || []
  erb :trainers, layout: :layout
end

post "/trainers/new" do
  session[:trainers] << params[:add_trainer]
  redirect "/trainers"
end

get "/trainees/:id" do
  @user = @storage.select_user(params[:id])
  erb :trainee, layout: :layout
end

get "/traineer/:id" do
  @user = @storage.select_user(params[:id]) || []
  erb :trainer, layout: :layout
end


get '/eval/:id' do
  @responses = @storage.load_eval(params[:id].to_i)


  puts "*************"
    @responses.each { |response| puts response}
    #@data.each { |ele| puts ele }
  puts "*************"
  erb :evaluation, layout: :layout
end
