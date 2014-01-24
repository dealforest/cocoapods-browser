module Pod
  class Command
    class Browser < Command
      self.summary = 'Open the homepage'

      self.description = <<-DESC
        Opens the homepage of a pod in the browser.
      DESC

      self.arguments = '[NAME]'

      def self.options
        [
          [ '--spec', 'Open the podspec in the browser. github.com/tree/master/[NAME].podspec' ],
        ].concat(super)
      end

      def initialize(argv)
        @spec  = argv.flag?('spec')
        @names = argv.arguments! unless argv.arguments.empty?
        super
      end

      def validate!
        super
        help! 'A Pod name is required' unless @names
      end

      extend Executable
      executable :open

      def run
#         update_specs_repos
        @names.each do |name|
          if spec = spec_with_name(name)
            UI.title "Opening #{spec.name}" do
              url = pick_open_url(spec)
              UI.puts(">>> #{url}")
              open!(url)
            end
          end
        end
      end

      def update_specs_repos
        unless config.skip_repo_update?
          UI.section 'Updating spec repositories' do
            SourcesManager.update
          end
        end
      end

      def spec_with_name(name)
        if set = SourcesManager.search(Dependency.new(name))
          set.specification.root
        else
          raise Informative, "Unable to find a podspec named `#{name}`"
        end
      end

      def pick_open_url(spec)
        url = spec.homepage
        if @spec && url =~ %r|^https?://github.com/|
          "%s/tree/master/%s.podspec" % [ url, spec.name ]
        else
          url
        end
      end

    end
  end
end
