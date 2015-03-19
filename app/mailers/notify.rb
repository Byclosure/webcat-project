class Notify < ActionMailer::Base
  include Emails::Projects
  include Emails::Profile
  include Emails::Groups

  add_template_helper ApplicationHelper
  add_template_helper GitlabMarkdownHelper

  default_url_options[:host]     = Gitlab.config.gitlab.host
  default_url_options[:protocol] = Gitlab.config.gitlab.protocol
  default_url_options[:port]     = Gitlab.config.gitlab.port unless Gitlab.config.gitlab_on_standard_port?
  default_url_options[:script_name] = Gitlab.config.gitlab.relative_url_root

  default from: Proc.new { default_sender_address.format }
  default reply_to: "noreply@#{Gitlab.config.gitlab.host}"

  private

  # The default email address to send emails from
  def default_sender_address
    address = Mail::Address.new(Gitlab.config.gitlab.email_from)
    address.display_name = "GitLab"
    address
  end

  # Return an email address that displays the name of the sender.
  # Only the displayed name changes; the actual email address is always the same.
  def sender(sender_id)
    if sender = User.find(sender_id)
      address = default_sender_address
      address.display_name = sender.name
      address.format
    end
  end

  # Look up a User by their ID and return their email address
  #
  # recipient_id - User ID
  #
  # Returns a String containing the User's email address.
  def recipient(recipient_id)
    if recipient = User.find(recipient_id)
      recipient.email
    end
  end

  # Formats arguments into a String suitable for use as an email subject
  #
  # extra - Extra Strings to be inserted into the subject
  #
  # Examples
  #
  #   >> subject('Lorem ipsum')
  #   => "Lorem ipsum"
  #
  #   # Automatically inserts Project name when @project is set
  #   >> @project = Project.last
  #   => #<Project id: 1, name: "Ruby on Rails", path: "ruby_on_rails", ...>
  #   >> subject('Lorem ipsum')
  #   => "Ruby on Rails | Lorem ipsum "
  #
  #   # Accepts multiple arguments
  #   >> subject('Lorem ipsum', 'Dolor sit amet')
  #   => "Lorem ipsum | Dolor sit amet"
  def subject(*extra)
    subject = ""
    subject << "#{@project.name} | " if @project
    subject << extra.join(' | ') if extra.present?
    subject
  end
end
