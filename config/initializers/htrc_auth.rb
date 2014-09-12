
require 'devise/strategies/authenticatable'
require 'rexml/document'

#
# Custom Devise strategy using the HTRC agent for 
# authentication. Given a username and password, get the
# Oauth token used for subsequent agent calls.
#

module Devise
  module Strategies
    class HtrcAuth < Authenticatable
     
      agent_url = APP_CONFIG['agent_url']

      def valid?
        #puts "PARAMS: #{params}"

        if (params[:user])
           params[:user][:email] || params[:user][:password]
        else
           false
        end
      end

      def authenticate!
        #puts "AUTHENTICATE: #{params}"

        email = params[:user][:email]
        password = params[:user][:password]
        token = login(email, password )
        #puts "TOKEN: #{token}"

        if (token)
          # create user account if none exists
          session[:token] = token
          user = User.find(:first, :conditions => { :email => email }) || User.create({ :email => email })
          success!(user)
        else
          fail!("Login failed")
        end
      end

      def login(username, password)
        #puts "LOGIN: username=#{username} password=#{password}"

        return false if username.blank? or password.blank?

        url = URI.parse('#{agent_url}/login')

        http = Net::HTTP.new(url.host, url.port)
        http.set_debug_output($stdout)

        request = Net::HTTP::Put.new(url.path)
        request.body = "<?xml version='1.0' encoding='UTF-8'?>" +
                       "<credentials>" +
                       "<username>#{username}</username>" +
                       "<password>#{password}</password>" +
                       "</credentials>";

        request["Content-Type"] = "text/xml"
        response = http.request(request)
        
        #puts "Response Code: #{response.code}"
  
        if (response.code == "200")
           xml = response.body
           #puts "Response Body: #{xml}"
  
           doc = REXML::Document.new(xml)
           token = doc.elements["/agent/token"][0]
           #puts "Token: #{token}"
           return token
       else
           return nil
       end
  
      end

   end
  end
end

Warden::Strategies.add(:htrc_auth, Devise::Strategies::HtrcAuth)
