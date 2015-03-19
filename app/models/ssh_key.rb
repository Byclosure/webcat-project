class SshKey < ActiveRecord::Base
  belongs_to :user

  attr_accessible :user, :private_key, :public_key

  def self.create_keys!(user)
    k = SSHKey.generate
    SshKey.create!(user: user,
      private_key: k.private_key,
      public_key: k.ssh_public_key
      )
  end
end