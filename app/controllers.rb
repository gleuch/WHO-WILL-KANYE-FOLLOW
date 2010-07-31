def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end




get '/leaders' do
  # @leaders = Person.all(:limit => 10, :order => [:votes_count.desc]) rescue nil
end

post '/' do

  # Do error check
  # Store in session if not ready
  # session[:person] = params[:person]
  
  unless @user.blank?
    voted = user_vote(params[:person])
    redirect '/'
  else
    session[:person] = {}
    params[:person].each{|k,v| session[:person][k.to_sym] = v }
    puts session[:person].inspect
    redirect '/connect'
  end

end

get '/' do
  limit = 10
  @people = Person.find_by_sql("SELECT id, name, screen_name, avatar_url FROM users WHERE (avatar_url IS NOT NULL AND avatar_url != '') ORDER BY RAND() LIMIT #{limit}")

  haml :home
end





# Twitter OAuth connect!

get_or_post '/connect' do
  @title = 'Connect to Twitter'
  twitter_connect
  
  begin
    puts 
    request_token = @twitter_client.request_token(:oauth_callback => "http://#{request.env['HTTP_HOST']}/connect/auth")

    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    puts session.inspect
    puts "----"

    redirect request_token.authorize_url.gsub('authorize', 'authenticate')
  rescue
    puts "Error: #{$!}"
    twitter_fail('An error has occured while trying to authenticate with Twitter. Please try again.')
  end
end

get '/connect/auth' do
  @title = 'Authenticate with Twitter'  

  unless params[:denied].blank?
    @error = "We are sorry that you decided to not use #{configatron.site_name}. <a href=\"/\">Click</a> to return."
    haml :fail
  else
    twitter_connect

    @access_token = @twitter_client.authorize(session[:request_token], session[:request_token_secret], :oauth_verifier => params[:oauth_verifier])

    if @twitter_client.authorized?
      begin
        info = @twitter_client.info
      rescue
        twitter_fail and return
      end

      @user = User.first(:conditions => ["account_id = ? OR LOWER(screen_name) = ?", info['id'], info['screen_name'].downcase]) rescue nil
      @user ||= User.new
      @user.active        = true
      @user.account_id    = info['id']
      @user.screen_name   = info['screen_name']
      @user.name          = info['name']
      @user.avatar_url    = info['profile_image_url']
      @user.oauth_token   = @access_token.token
      @user.oauth_secret  = @access_token.secret
      @user.save

      # Set and clear session data
      session[:user] = @user.id
      session[:account] = @user.account_id
      session[:request_token] = nil
      session[:request_token_secret] = nil

    end

    user_vote(session[:person]) unless session[:person].blank?
    session[:person] = nil

    redirect '/'
  end

end