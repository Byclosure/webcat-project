class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  Gitlab.config.omniauth.providers.each do |provider|
    define_method provider['name'] do
      handle_omniauth
    end
  end

  # Extend the standard message generation to accept our custom exception
  def failure_message
    exception = env["omniauth.error"]
    error   = exception.error_reason if exception.respond_to?(:error_reason)
    error ||= exception.error        if exception.respond_to?(:error)
    error ||= exception.message      if exception.respond_to?(:message)
    error ||= env["omniauth.error.type"].to_s
    error.to_s.humanize if error
  end

  def ldap
    # We only find ourselves here
    # if the authentication to LDAP was successful.
    @user = Gitlab::LDAP::User.find_or_create(oauth)
    @user.remember_me = true if @user.persisted?
    sign_in_and_redirect(@user)
  end

  private

  def handle_omniauth
    if current_user
      # Change a logged-in user's authentication method:
      begin
        if(current_user.provider == oauth['provider'])
          remove_provider!
        else
          change_provider!(oauth)
        end

        flash[:notice] = "Changes successfully saved"
      rescue
        flash[:alert] = "Could not save changes"
      end

      redirect_to profile_path
    else
      @user = Gitlab::OAuth::User.find(oauth)

      # Create user if does not exist
      # and allow_single_sign_on is true
      if Gitlab.config.omniauth['allow_single_sign_on']
        @user ||= Gitlab::OAuth::User.create!(oauth)
      end

      if @user
        sign_in_and_redirect(@user)
      else
        flash[:alert] = "There's no such user!"
        redirect_to new_user_session_path
      end
    end
  end

  def oauth
    @oauth ||= request.env['omniauth.auth']
  end

  private
  def change_provider!(oauth)
    ActiveRecord::Base.transaction do
      current_user.extern_uid = oauth['uid']
      current_user.provider = oauth['provider']
      current_user.save!
    end
  end

  def remove_provider!
    ActiveRecord::Base.transaction do
      current_user.extern_uid = nil
      current_user.provider = nil
      current_user.save!
    end
  end
end