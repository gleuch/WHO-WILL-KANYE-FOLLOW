class Person
  include DataMapper::Resource

  property  :id,            Serial
  property  :name,          String
  property  :screen_name,   String
  property  :avatar_url,    String,       :length => 255
  property  :vote_count,    Integer,      :default => 0
  property  :active,        Boolean,      :default => true
  property  :created_at,    DateTime
  property  :updated_at,    DateTime

  has n,  :votes
  # has n,  :users # Through votes
end


class Vote
  include DataMapper::Resource

  property  :id,          Serial
  property  :person_id,   Integer
  property  :user_id,     Integer
  # property  :session_id,  String,       :length => 128
  property  :ip_address,  String,       :length => 15
  property  :created_at,  DateTime

  belongs_to  :person
  belongs_to  :user
end


class User
  include DataMapper::Resource

  property  :id,                Serial
  property  :account_id,        String
  property  :name,              String
  property  :screen_name,       String
  property  :avatar_url,        String,       :length => 255
  property  :oauth_token,       String,       :length => 255
  property  :oauth_secret,      String,       :length => 255
  property  :active,            Boolean,      :default => true
  property  :permission_level,  Integer,      :default => 0
  property  :created_at,        DateTime
  property  :updated_at,        DateTime

  has n,  :votes
  # has n,  :persons, # Through votes -- how?

  def smart?; self.permission_level = 2; end
end