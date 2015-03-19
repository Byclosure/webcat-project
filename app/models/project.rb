require 'url_validator'
require 'tempfile'

# == Schema Information
#
# Table name: projects
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  path                   :string(255)
#  description            :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  creator_id             :integer
#  issues_enabled         :boolean          default(TRUE), not null
#  wall_enabled           :boolean          default(TRUE), not null
#  merge_requests_enabled :boolean          default(TRUE), not null
#  wiki_enabled           :boolean          default(TRUE), not null
#  namespace_id           :integer
#  issues_tracker         :string(255)      default("gitlab"), not null
#  issues_tracker_id      :string(255)
#  snippets_enabled       :boolean          default(TRUE), not null
#  last_activity_at       :datetime
#  imported               :boolean          default(FALSE), not null
#  import_url             :string(255)
#  visibility_level       :integer          default(0), not null
#

class Project < ActiveRecord::Base

  class CiBuild
    SINGLE    = 1
    ALL       = 2

    attr_accessor :url, :number, :status, :timestamp, :type

    def initialize(attrs = {})
      @number = attrs["number"]
      @type = ALL
    end
  end

  attr_accessible :name, :git_url, :description, :ci_url,
      :ci_username, :ci_password, :ci_job_name, :passed_goal, :automation_goal,
      :test_path, :ci_schedule

  # Relations
  belongs_to :creator,      foreign_key: "creator_id", class_name: "User"
  belongs_to :group, -> { where(type: Group) }, foreign_key: "namespace_id"
  belongs_to :namespace

  has_many :users_projects, dependent: :destroy
  has_many :users, through: :users_projects

  has_many :builds
  
  delegate :name, to: :owner, allow_nil: true, prefix: true
  delegate :members, to: :team, prefix: true

  # Validations
  validates :creator, presence: true, on: :create
  validates :description, length: { maximum: 2000 }, allow_blank: true
  validates :name, presence: true, length: { within: 0..255 },
            format: { with: Gitlab::Regex.project_name_regex,
                      message: "only letters, digits, spaces & '_' '-' '.' allowed. Letter or digit should be first" }
  validates :path, presence: true, length: { within: 0..255 },
            exclusion: { in: Gitlab::Blacklist.path },
            format: { with: Gitlab::Regex.path_regex,
                      message: "only letters, digits & '_' '-' '.' allowed. Letter or digit should be first" }

  validates :namespace, presence: true
  validates_uniqueness_of :name, scope: :namespace_id, message: "has already been taken. Please change your Project name."
  validates_uniqueness_of :path, scope: :namespace_id, message: "has already been taken. Please change your Project name."

  #Webcat token
  validates :webcat_token, presence: true
  before_validation :generate_webcat_token, on: :create
  
  # Scopes
  scope :in_team, ->(team) { where("projects.id IN (:ids)", ids: team.projects.map(&:id)) }
  scope :in_namespace, ->(namespace) { where(namespace_id: namespace.id) }
  
  class << self
    
    def accessible_to(user)
      accessible_ids = user.authorized_projects.pluck(:id) if user
      where(id: accessible_ids)
    end

    def find_with_namespace(id)
      if id.include?("/")
        id = id.split("/")
        namespace = Namespace.find_by(path: id.first)
        return nil unless namespace

        where(namespace_id: namespace.id).find_by(path: id.second)
      else
        where(path: id, namespace_id: nil).last
      end
    end
  end

  def team
    @team ||= ProjectTeam.new(self)
  end

  def repository(username = nil)
    @repository ||= (username.nil? ? Repository.new(path_with_namespace) : Repository.new(path_with_namespace_with_user(username)))
  end

  def pull_repository!(user = nil)
    user_id = if(user.nil?)
        Thread.current[:current_user].id
      else
        user.id
      end 
    k = SshKey.where(user_id: user_id).first
    repository.pull!(k)
  end

  def clone_repository!(user = nil)
    user_id = if(user.nil?)
        Thread.current[:current_user].id
      else
        user.id
      end

    k = SshKey.where(user_id: user_id).first
    repository.clone!(git_url, k)
  end

  def saved?
    !id.nil?
  end

  def to_param
    namespace.path + "/" + path
  end

  def last_activity_date
    last_activity_at || updated_at
  end

  def project_id
    self.id
  end

  # For compatibility with old code
  def code
    path
  end

  def owner
    if group
      group
    else
      namespace.try(:owner)
    end
  end

  def team_member_by_name_or_email(name = nil, email = nil)
    user = users.where("name like ? or email like ?", name, email).first
    users_projects.where(user: user) if user
  end

  # Get Team Member record by user id
  def team_member_by_id(user_id)
    users_projects.find_by(user_id: user_id)
  end

  def name_with_namespace
    @name_with_namespace ||= begin
                               if namespace
                                 namespace.human_name + " / " + name
                               else
                                 name
                               end
                             end
  end

  def path_with_namespace
    path_with_namespace_with_user(Thread.current[:current_user].username)
  end

  def public?
    #no project is public
    false
  end

  def path_with_namespace_with_user(username)
    if namespace
      username + '/' + namespace.path + '/' + path
    else
      username + '/' + path
    end
  end

  def valid_repo?
    repository.exists?
  rescue
    errors.add(:path, "Invalid repository path")
    false
  end

  def empty_repo?
    !repository.exists? || repository.empty?
  end

  def repo
    repository.raw
  end

  def url_to_repo
    path_with_namespace
  end

  def namespace_dir
    namespace.try(:path) || ''
  end

  def repo_exists?
    @repo_exists ||= repository.exists?
  rescue
    @repo_exists = false
  end

  def root_ref?(branch)
    repository.root_ref == branch
  end

  def ssh_url_to_repo
    url_to_repo
  end

  def http_url_to_repo
    [Gitlab.config.gitlab.url, "/", path_with_namespace, ".git"].join('')
  end

  def project_member(user)
    users_projects.where(user_id: user).first
  end

  def default_branch
    @default_branch ||= repository.root_ref if repository.exists?
  end

  def reload_default_branch
    @default_branch = nil
    default_branch
  end
  
  def change_head(branch)
    gitlab_shell.update_repository_head(self.path_with_namespace, branch)
    reload_default_branch
  end

  # FIXME this Satellite dependency should be removed
  def satellite
    @satellite ||= Gitlab::Satellite::Satellite.new(self)
  end


  ####### Webcat
  def ci_schedule
    if has_ci_settings?
      client = JenkinsApi::Client.new(server_url: ci_url, username: ci_username, password: ci_password)
      job_config = client.job.get_config(ci_job_name)
      xml_config = Nokogiri::XML(job_config)
      xml_config.xpath("//triggers/hudson.triggers.TimerTrigger/spec/text()").first
    end
  end

  def ci_schedule=(value)
    if has_ci_settings?
      client = JenkinsApi::Client.new(server_url: ci_url, username: ci_username, password: ci_password)
      
      insert_schedule_config(client, value)
    end
  end

  def ci_run_job(user_token)
    client = JenkinsApi::Client.new(server_url: ci_url, username: ci_username, password: ci_password)
    build_number = client.job.build(ci_job_name, job_params(user_token))
  end

  def ci_single_job_name
    ci_job_name+'-single'
  end

  def ci_run_single_job(user_token, commit_sha, testname)
    client = JenkinsApi::Client.new(server_url: ci_url, username: ci_username, password: ci_password)
    client.job.build(ci_job_name, single_job_params(user_token, commit_sha, testname))
  end

  def ci_report_url_fragment
    "webcat-cucumber-html-reports/"
  end

  def report_url(build_url)
    "#{build_url}#{ci_report_url_fragment}"
  end

  def cibuilds
    if has_ci_settings?
      client = JenkinsApi::Client.new(server_url: ci_url, username: ci_username, password: ci_password)

      ci_builds = map_builds(ci_job_name, client, CiBuild::ALL)
      ci_builds.concat map_builds(ci_single_job_name, client, CiBuild::SINGLE)

      ci_builds.sort_by(&:timestamp).reverse
    else
      []
    end
  end

  def map_builds(job_name, client, type)
    ci_builds = client.job.get_builds(job_name)

    ci_builds.map do |b|
      bld = CiBuild.new(b)
      bld.url = report_url(b["url"])
      build_details = client.job.get_build_details(job_name, bld.number)
      bld.status = build_details["result"]
      bld.timestamp = build_details["timestamp"]
      bld.type = type
      bld
    end
  end

  def clean_repository!
    team.users.each do |member|
      Repository.clean_local_copy!(path_with_namespace_with_user(member.username))
    end
  end

  def has_ci_settings?
    !(ci_url.nil? || ci_url.empty? ||
      ci_username.nil? || ci_username.empty? ||
      ci_password.nil? || ci_password.empty? ||
      ci_job_name.nil? || ci_job_name.empty?)
  end

  def generate_webcat_token
    self.webcat_token ||= SecureRandom.hex
  end

  def default_branch
    "master"
  end

  private
  def insert_schedule_config(client, value)

    job_config = client.job.get_config(ci_job_name)
    xml_config = Nokogiri::XML(job_config)
    triggers = xml_config.xpath("//triggers")
    triggers.children.each { |node| node.remove }
    
    unless value.nil? || value.empty?
      hudson_node = Nokogiri::XML::Node.new("hudson.triggers.TimerTrigger", xml_config)
      spec_node = Nokogiri::XML::Node.new("spec", xml_config)
      spec_node.content = value
      hudson_node.add_child(spec_node)
      triggers.first.add_child(hudson_node)
    end

    client.job.post_config(ci_job_name, xml_config.to_s)
  end

  def job_params(user_token)
    params = basic_job_params(user_token)
    params["WEBCAT_INTENT"] = WebcatIntent.ci.to_json

    params
  end

  def single_job_params(user_token, sha, feature)
    params = basic_job_params(user_token, sha)
    params["WEBCAT_INTENT"] = WebcatIntent.single_feature(feature).to_json
    
    params
  end

  def basic_job_params(user_token, sha = nil)
    params = {
      "WEBCAT_USER_TOKEN" => user_token,
      "COMMIT_ID" => sha || default_branch
    }
    
    params
  end

end
