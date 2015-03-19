# encoding: utf-8

require "mail"

class Notifications < ActionMailer::Base

  def self.format_email(name, email)
    email_address = Mail::Address.new email
    email_address.display_name = name
    email_address.format
  end
  
  def self.system_email(name, email)
    format_email("Webcat - #{name}", email)
  end

  def format_email(name, email)
    self.class.format_email(name, email)
  end

  SIGNING_DOMAIN = "webcat.byclosure.com"
  SALES_EMAIL = system_email("Sales", "sales@byclosure.com")
  SUPPORT_EMAIL = system_email("Support", "info@byclosure.com")
  NOREPLY_EMAIL = system_email("No Reply", "noreply@byclosure.com")

  def new_account(name, email)
    mail(:from => NOREPLY_EMAIL, :to => SALES_EMAIL, :subject => "[Webcat] New Account: #{email}", body: "")
    headers["X-MC-SigningDomain"] = SIGNING_DOMAIN
    headers["X-MC-Template"] = "webcat-newSignUpNotification"
    headers["X-MC-Subaccount"] = "webcat"
    headers["X-MC-MergeVars"] = {
      "name" => s_to_utf8(name) || "",
      "email" => email || "",
    }.to_json
  end
  
  def welcome_account(name, email, locale)
    mail(:from => SUPPORT_EMAIL, :to => format_email(name, email), :subject => "Webcat | #{I18n.t(:welcome)} " + s_to_utf8(name) + "!", body: "")
    I18n.locale = locale
    headers["X-MC-SigningDomain"] = SIGNING_DOMAIN
    headers["X-MC-Template"] = "webcat-welcome-#{locale}"
    headers["X-MC-Subaccount"] = "webcat"
    headers["X-MC-MergeVars"] = {
      "name" => s_to_utf8(name) || email || "",
    }.to_json
  end

  def s_to_utf8(string)
    string.nil? ? "" : string.force_encoding("UTF-8")
  end
end