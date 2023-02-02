require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "date"


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

# convienence functions
def load_form(index)
  form = session[:forms][index] if index <= session[:forms].size
  return form if form

  session[:error] = "That form does not exist"
  redirect  "/forms"
end 

def save_blank_form(form)

end 

get "/" do 
  erb :index, layout: :layout
end

get "/forms/create" do 
  erb :create, layout: :layout
end 

post "/forms/create" do
  form_id = session[:forms].size

  session[:forms] << { document_name: params[:document_name], criteria: [], form_id: form_id} 
  save_blank_form
  redirect "/forms/#{form_id}/edit"
end 

post "/forms/:form_id/delete/:item_id" do
  form_id = params[:form_id].to_i
  item_id = params[:item_id].to_i

  current_form = session[:forms][form_id]
  current_form[:criteria].delete_at(item_id)

  redirect "/forms/#{form_id}/edit"
end 

post "/forms/:form_id/delete" do
  form_id = params[:form_id].to_i
  session[:forms].delete_at(form_id)

  redirect "/forms/#{form_id}/edit"
end

get "/forms" do
  @forms = session[:forms]
  erb :forms, layout: :layout
end 

get "/forms/:form_id" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)
  
  @form_name = form[:document_name] 

  @criteria = form[:criteria]
  
  erb :view_form, layout: :layout
end

get "/forms/:form_id/edit" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)
  
  @form_name = form[:document_name] 

  @criteria = form[:criteria]
  
  erb :form_edit,layout: :layout 
end


post "/forms/:form_id/criteria" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)
  
  @criteria = form[:criteria]

  @criteria << { text: params[:text], type: "graded_criteria" }

  redirect "/forms/#{@form_id}/edit"
end

post '/forms/0/save' do
  session[:params]
  
end

post "/forms/:form_id/section-header" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)
  
  @criteria = form[:criteria]

  @criteria << { text: params[:text], type: "section_header"}

  redirect "/forms/#{@form_id}/edit"
end

post "/forms/:form_id/text-box" do
  @form_id = params[:form_id].to_i
  form = load_form(@form_id)
  
  @criteria = form[:criteria]

  @criteria << { text: params[:text], type: "text_box" }

  redirect "/forms/#{@form_id}/edit"
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



