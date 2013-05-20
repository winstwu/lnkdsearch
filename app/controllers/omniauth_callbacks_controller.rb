class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	@@config = { 
    :site => 'https://api.linkedin.com',
    :authorize_path => '/uas/oauth/authenticate',
    :request_token_path => '/uas/oauth/requestToken?scope=r_basicprofile+r_fullprofile',   
    :access_token_path => '/uas/oauth/accessToken' 
  }

	def all
		user = User.from_omniauth(request.env["omniauth.auth"])
		session[:usertest] = user
		session[:token] = user.token
		session[:secret] = user.secret
		client = LinkedIn::Client.new('gu7dbvwzvog2', 'ENg82itfHPKuSTnR')
		session[:pin] = client.request_token.authorize_url
		client.authorize_from_access(session[:token], session[:secret])
		client
		#raise request.env["omniauth.auth"].to_yaml
		if user.persisted?
			flash.notice = "Signed in!"			
			sign_in_and_redirect user
		else
			session["devise.user_attributes"] = user.attributes
			redirect_to new_user_registration_url
		end
	end
	alias_method :linkedin, :all

	def oauth_account
	  client = LinkedIn::Client.new('gu7dbvwzvog2', 'ENg82itfHPKuSTnR', @@config)
	  pin = params[:oauth_verifier]
	  if pin
	    atoken, asecret = client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
	    LinkedinOauthSetting.create!(:asecret => asecret, :atoken => atoken, :user_id => current_user.id)
	  end
	  redirect_to "/"
	end
end
