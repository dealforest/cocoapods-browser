module Pod
  class Command
    class Browse < Command
      self.summary = 'Open the homepage'

      self.description = <<-DESC
        Opens the homepage of a pod in the browser.
      DESC

      self.arguments = [['[NAME]', :optional]]

      def self.options
        [
          [ '--spec', 'Open the podspec in the browser.' ],
          [ '--release', 'Open the releases in the browser.' ],
        ].concat(super)
      end

      def initialize(argv)
        @spec    = argv.flag?('spec')
        @release = argv.flag?('release')
        @names   = argv.arguments! unless argv.arguments.empty?
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
          if specs = specs_with_name(name)
            specs.each do |spec|
              UI.title "Opening #{spec.name}" do
                url = pick_open_url(spec)
                open!(url)
              end
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

      def specs_with_name(name)
        specs = []
        if set = SourcesManager.search(Dependency.new(name))
          specs << set.specification.root
        elsif sets = Pod::SourcesManager.search_by_name(name)
          case sets.size
          when 1
            specs << sets.first.specification.root
          else
            UI.title 'Please select a pod:'
            text = ''
            statistics_provider = Config.instance.spec_statistics_provider
            sets.each_with_index do |s, i|
              pod = Specification::Set::Presenter.new(s, statistics_provider)
              text << "  [#{i + 1}]\t#{formated_name(pod)}\n"
            end
            UI.puts text
            print "> (1-#{sets.size}) "
            input = $stdin.gets
            raise Interrupt unless input

            range = 1..sets.size
            input.split(',').each do |i|
              index = i.try(:strip).to_i
              specs << sets[index - 1].specification.root if range.include?(index)
            end
            raise Informative, 'invalid input value' if specs.empty?
          end
        else
          raise Informative, "Unable to find a podspec named `#{name}`"
        end
        specs
      end

      def formated_name(pod)
        "%-40s (Watchers: %5s, Forks: %5s, Pushed: %s)" % [
          pod.name.green,
          pod.github_watchers || '-',
          pod.github_forks || '-',
          pod.github_last_activity.try(:yellow) || '-',
        ]
      end

      def pick_open_url(spec)
        url = spec.homepage
        if @spec && url =~ %r|^https?://github.com/|
          "%s/tree/master/%s.podspec" % [ url, spec.name ]
        elsif @release && url =~ %r|^https?://github.com/|
          "%s/releases" % [ url ]
        else
          url
        end
      end

    end
  end
end
