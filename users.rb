class Users
  def login()
    username = params[:username].strip
    password = params[:password].strip

    url = session[:url] || 'forum/index'
    user_data = @storage.load_user_data(username)


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

  # Clear session data / logout user
  get '/logout' do
    session.clear
    session[:message] = 'You have be logged out.'
    redirect '/home'
  end
end
