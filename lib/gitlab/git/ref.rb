module Gitlab
  module Git
    class Ref
      # Branch or tag name
      # without "refs/tags|heads" prefix
      attr_reader :name

      # Target sha.
      # Usually it is commit sha but in case
      # when tag reference on other tag it can be tag sha
      attr_reader :target

      # Extract branch name from full ref path
      #
      # Ex.
      #   Ref.extract_branch_name('refs/heads/master') #=> 'master'
      def self.extract_branch_name(str)
        str.gsub(/\Arefs\/heads\//, '')
      end

      def self.extract_remote_branch_name(str)
        str.gsub(/\Arefs\/remotes\/origin\//, '')
      end

      def initialize(name, target)
        @name, @target = name.gsub(/\Arefs\/(tags|heads|remotes\/origin)\//, ''), target
      end
    end
  end
end
