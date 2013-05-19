class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	def all
		user = User.from_omniauth(request.env["omniauth.auth"])
		session[:usertest] = user
		session[:token] = user.token
		session[:secret] = user.secret
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
end
