class UserLeadController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :create

  def create
    user_name, user_email = params[:name], params[:email]

    begin
      UserLead.create!(name: user_name, email: user_email)
      send_emails!(user_name, user_email, "en")
      render json: { "success" => true }
    rescue ActiveRecord::RecordInvalid => e
      e.message.slice!("Validation failed: ")
      render status: 422, json: {"success" => false, "message" => e.message }
    rescue
      render status: 500, json: {"success" => false, "message" => "Someting went wrong" }
    end
  end

  private
  def send_emails!(name, email, locale)
    Notifications.new_account(name, email).deliver
    Notifications.welcome_account(name, email, locale).deliver
  end
end
