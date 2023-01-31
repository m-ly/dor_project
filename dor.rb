require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"


configure do 
  enable :sessions
  set "session_secret", SecureRandom.hex(32)
end 

before do 
  @users = [ {admin: []}, {trainers: []}, {trainees: []}]
  session[:forms] ||= []
  session[:trainers] ||= []
  session[:trainees] ||=[]
end

def load_users
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
  YAML.load_file(credentials_path)
end 

get "/" do 
  erb :index, layout: :layout
end

get "/forms/create" do 
  erb :create, layout: :layout
end 

post "/forms/create" do
  @form_id = 0 
 
  session[:forms] << { document_name: params[:document_name], criteria: [], form_id: @form_id +=1 } 
  redirect "/forms/#{@form_id}"
end 

get "/forms" do
  @forms = session[:forms]
  erb :forms, layout: :layout
end 


# Loading a specific form 
def load_form(index)
  form = session[:forms][index] if index <= session[:forms].size
  return form if form

  session[:error] = "That form does not exist"
  redirect  "/forms"
end 

def load_segment(criteria)
  if params[:criteria]
  end
    
end

get "/forms/:form_id" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)
  
  @form_name = form[:document_name] 

  @criteria = form[:criteria]
  
  erb :view_form, layout: :layout
end

post "/forms/:form_id" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)
  
  @criteria = form[:criteria]
 
  @criteria << params[:criteria]
  
  redirect "/forms/#{@form_id}"
end

get "/trainees" do
  @trainees = session[:trainees]
  erb :trainees, layout: :layout
end

post "/trainees/new" do 
  session[:trainees] << params[:add_trainee]
  redirect "/trainees"
end 

get "/trainers" do 
  @trainers = session[:trainers]
  erb :trainers, layout: :layout
end

post "/trainers/new" do 
  session[:trainers] << params[:add_trainer]
  redirect "/trainers"
end 



get "/trainees/:trainee" do
  @trainee = params[:trainee]
  erb :trainee, layout: :layout
end 



