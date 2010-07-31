helpers do

  def dev?; (Sinatra::Application.environment.to_s != 'production'); end

  def twitter_connect(user={})
    @twitter_client = TwitterOAuth::Client.new(:consumer_key => configatron.twitter_oauth_token, :consumer_secret => configatron.twitter_oauth_secret, :token => (!user.blank? ? user.oauth_token : nil), :secret => (!user.blank? ? user.oauth_secret : nil)) rescue nil
  end

  def twitter_fail(msg=false)
    @error = (!msg.blank? ? msg : 'An error has occured while trying to talk to Twitter. Please try again.')
    haml :fail and return
  end

  def partial(name, options = {})
    item_name, counter_name = name.to_sym, "#{name}_counter".to_sym
    options = {:cache => true, :cache_expiry => 300}.merge(options)

    if collection = options.delete(:collection)
      collection.enum_for(:each_with_index).collect{|item, index| partial(name, options.merge(:locals => { item_name => item, counter_name => index + 1 }))}.join
    elsif object = options.delete(:object)
      partial(name, options.merge(:locals => {item_name => object, counter_name => nil}))
    else
      unless options[:cache].blank?
        cache "_#{name}", :expiry => (options[:cache_expiry].blank? ? 300 : options[:cache_expiry]), :compress => false do
          haml "_#{name}".to_sym, options.merge(:layout => false)
        end
      else
        haml "_#{name}".to_sym, options.merge(:layout => false)
      end
    end
  end

  # Modified from Rails ActiveSupport::CoreExtensions::Array::Grouping
  def in_groups_of(item, number, fill_with = nil)
    if fill_with == false
      collection = item
    else
      padding = (number - item.size % number) % number
      collection = item.dup.concat([fill_with] * padding)
    end

    if block_given?
      collection.each_slice(number) { |slice| yield(slice) }
    else
      returning [] do |groups|
        collection.each_slice(number) { |group| groups << group }
      end
    end
  end


  def user_profile_url(screen_name, at=true)
    "<a href='http://www.twitter.com/#{screen_name || ''}' target='_blank'>#{at ? '@' : ''}#{screen_name || '???'}</a>"
  end


  def user_vote(opts = {})
    return false if opts.blank?
    begin
      @person = Person.first(:conditions => [ "LOWER(screen_name) = ?", opts[:screen_name].downcase ]) rescue nil
      @person ||= Person.create(:screen_name => opts[:screen_name]) rescue nil

      @vote = Vote.first(:user_id => @user.id, :person_id => @person.id, :created_at.lte => Time.now-600) rescue nil
      if @vote.blank?
        @vote ||= Vote.create(:user_id => @user.id, :person_id => @person.id, :ip_address => '') rescue nil

        # spock = Spork.spork(:logger => false) do
          begin
            twitter_connect(@user)
            @twitter_client.update(opts[:tweet]) unless dev?  
          rescue
            STDERR.puts "Could not tweet @#{@user.screen_name}'s vote for @#{opts[:screen_name]}"
          end
        # end

        flash[:notice] = "You successfully voted for @#{@person.screen_name}."
      else
        flash[:error] = "You're on Love Lockdown for 10 minutes with @#{@person.screen_name}. Suggest another person for #{configatron.targeted_person} to follow!"
      end

      return true
    rescue => err
      @error = "Could not save your vote: #{err}"
      return false
    end
  end

end