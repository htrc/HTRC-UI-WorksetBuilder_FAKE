class User < ActiveRecord::Base

  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid, :name if Rails::VERSION::MAJOR < 4
# Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :timeoutable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def self.find_for_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create!(
          :uid => auth.uid,
          :email => auth.info.email,
          :name => auth.info.name,
          :provider => auth.provider,
          :password => Devise.friendly_token[0,20]
      )
    end
    user
  end

end
