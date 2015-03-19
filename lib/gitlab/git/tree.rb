module Gitlab
  module Git
    class Tree
      attr_accessor :id, :root_id, :name, :path, :type,
        :mode, :commit_id, :submodule_url

      class << self
        # Get list of tree objects
        # for repository based on commit sha and path
        # Uses rugged for raw objects
        def where(repository, sha, path = nil)
          path = nil if path == '' || path == '/'

          commit = repository.lookup(sha)
          root_tree = commit.tree

          tree = if path
                   id = Tree.find_id_by_path(repository, root_tree.oid, path)
                   if id
                     repository.lookup(id)
                   else
                     []
                   end
                 else
                   root_tree
                 end

          tree.map do |entry|
            Tree.new(
              id: entry[:oid],
              root_id: root_tree.oid,
              name: entry[:name],
              type: entry[:type] || :submodule,
              mode: entry[:filemode],
              path: path ? File.join(path, entry[:name]) : entry[:name],
              commit_id: sha,
            )
          end
        end

        # Recursive search of tree id for path
        #
        # Ex.
        #   blog/            # oid: 1a
        #     app/           # oid: 2a
        #       models/      # oid: 3a
        #       views/       # oid: 4a
        #
        #
        # Tree.find_id_by_path(repo, '1a', 'app/models') # => '3a'
        #
        def find_id_by_path(repository, root_id, path)
          root_tree = repository.lookup(root_id)
          path_arr = path.split('/')

          entry = root_tree.find do |entry|
            entry[:name] == path_arr[0] && entry[:type] == :tree
          end

          return nil unless entry

          if path_arr.size > 1
            path_arr.shift
            find_id_by_path(repository, entry[:oid], path_arr.join('/'))
          else
            entry[:oid]
          end
        end
      end

      def initialize(options)
        %w(id root_id name path type mode commit_id).each do |key|
          self.send("#{key}=", options[key.to_sym])
        end
      end

      def dir?
        type == :tree
      end

      def file?
        type == :blob
      end

      def submodule?
        type == :submodule
      end

      def readme?
        name =~ /^readme/i
      end

      def contributing?
        name =~ /^contributing/i
      end
    end
  end
end
