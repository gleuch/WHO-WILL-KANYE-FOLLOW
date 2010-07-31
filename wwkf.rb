require 'rubygems'
require 'sinatra'
require 'rack-flash'

# use Rack::Session::Cookie, :secret => 'SRSLYWTFKANYE?'
use Rack::Flash

configure do |config|
  requires = %w(twitter_oauth configatron haml dm-core dm-types dm-timestamps dm-aggregates dm-ar-finders app/libs app/models app/helpers app/controllers)
  # requires << 'sinatra/memcache'
  # requires << 'spork'
  requires.each{ |r| require r }


  ROOT = File.expand_path(File.dirname(__FILE__))
  configatron.configure_from_yaml("#{ROOT}/settings.yml", :hash => Sinatra::Application.environment.to_s)

  DataMapper.setup(:default, configatron.db_connection.gsub(/ROOT/, ROOT))
  DataMapper.auto_upgrade!

  set :cache_enable, (configatron.enable_memcache && Sinatra::Application.environment.to_s == 'production')
  set :cache_logging, false # causes problems if using w/ partials! :/
  set :sessions, true
  enable :sessions

  # set :views, File.dirname(__FILE__) + '/views/'+ configatron.template_name
  # set :public, File.dirname(__FILE__) + '/public/'+ configatron.template_name
end


before do
  unless session.blank? && session[:user].blank?
    @user = User.first(:id => session[:user]) rescue nil
  end
end


not_found do
  @error = 'Sorry, but the page you were looking for could not be found.</p><p><a href="/">Click here</a> to return to the homepage.'
  haml :fail
end


# 500 errors
error do
  haml :fail
end
