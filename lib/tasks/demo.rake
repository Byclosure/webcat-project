namespace :demo do

  desc "Creates a User 'Demo'"
  task :create_user => :environment do
    data = YAML::load(File.open(File.join("#{File.dirname(__FILE__)}", "demo_data.yml")))
    user_data = data['user'].deep_symbolize_keys

    webcat_token = user_data.delete(:webcat_token)
    ssh_key = user_data.delete(:ssh_key)

    username = user_data[:username]
    unless(User.exists?(username: username))
      puts "Creating Demo user"
      user = User.create!(user_data)
    else
      puts "Reseting Demo user"
      user = User.where(username: "demo").first
      user.update_attributes!(user_data)
    end
    
    user.webcat_token = webcat_token

    key = SshKey.where(user_id: user.id).first
    key.update_attributes!(ssh_key)
  end

  desc "Creates a project 'Demo Project'"
  task :create_project => :environment do
    data = YAML::load(File.open(File.join("#{File.dirname(__FILE__)}", "demo_data.yml")))
    project_data = data['project'].deep_symbolize_keys

    user = User.where(username: data['user']['username']).first
    project_name = project_data[:name]
    webcat_token = project_data.delete(:webcat_token)

    unless(Project.exists?(name: project_name))
    puts "Creating Demo project"
      project = Project.new(project_data)
    else
      puts "Reseting Demo project"
      project = Project.where(name: project_name).first
      project.update_attributes!(project_data)

      Build.where(project_id: project.id).delete_all
    end

    project.creator = user
    project.webcat_token = webcat_token
    project.path = project.name && project.name.parameterize
    project.namespace_id = user.namespace_id
    project.save!
  end

  task :clone_repository => :environment do
    data = YAML::load(File.open(File.join("#{File.dirname(__FILE__)}", "demo_data.yml")))
    user = User.where(username: data['user']['username']).first
    project = Project.where(name: data['project']['name']).first

    unless(project.repository(user.username).exists?)
      puts "Cloning repository"
      project.clone_repository!(user)
    end
  end

  task :create => [:create_user, :create_project, :clone_repository]
end