require 'open3'

module Gitlab
  module Git
    class Ssh
      def self.add_host(hostname)
        `ssh -T -o StrictHostKeyChecking=no #{hostname}`
      end

      private
      def self.known_hosts_path
        home_path = ENV['HOME']
        home_path += "root" if home_path == "/"
        File.join(home_path, ".ssh/known_hosts")
      end
    end
  end
end