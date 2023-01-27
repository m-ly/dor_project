require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"


configure do 
  enable :sessions
  set "session_secret", SecureRandom.hex(32)
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

get "/documents" do
  erb :documents
end 

get "/trainees" do
  @trainees = ['matt', 'jen', 'ashser', 'gibson']
  erb :trainees
end

get "/trainers" do 
  erb :trainers
end

