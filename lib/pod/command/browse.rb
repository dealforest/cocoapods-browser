module Pod
  class Command
    class Browse < Command
      self.summary = 'Open the homepage'

      self.description = <<-DESC
        Opens the homepage of a pod in the browser.
      DESC

      self.arguments = [ CLAide::Argument.new(%w(NAME), true) ]

      def self.options
        [
          ['--spec', 'Open the podspec in the browser.'],
          ['--release', 'Open the releases in the browser.'],
          ['--info', 'Show more pods information of github (very slowly)'],
        ].concat(super)
      end

      def initialize(argv)
        @spec = argv.flag?('spec')
        @release = argv.flag?('release')
        @info = argv.flag?('info')
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
        # update_specs_repos
        @names.each do |name|
          specs = specs_with_name(name)
          next unless specs

          specs.each do |spec|
            UI.message "Opening #{spec.name}" do
              url = pick_open_url(spec)
              open!(url)
            end
          end
        end
      end

      def update_specs_repos
        return if config.skip_repo_update?

        UI.section 'Updating spec repositories' do
          SourcesManager.update
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
            specs = interactive_select_sets(sets)
          end
        else
          raise Informative, "Unable to find a podspec named `#{name}`"
        end
        specs
      end

      def interactive_select_sets(sets)
        UI.puts "found #{sets.size} pods"
        UI.title 'Please select a pod:'

        statistics_provider = Config.instance.spec_statistics_provider
        sets.each_with_index do |s, i|
          pod = Specification::Set::Presenter.new(s, statistics_provider)
          UI.puts "  [#{i + 1}]\t#{formated_name(pod)}\n"
        end
        print "> (1-#{sets.size}) "
        input = $stdin.gets
        raise Interrupt unless input

        specs = []
        range = 1..sets.size
        input.split(',').each do |i|
          index = i.try(:strip).to_i
          specs << sets[index - 1].specification.root if range.include?(index)
        end
        raise Informative, 'invalid input value' if specs.empty?
        specs
      end

      def formated_name(pod)
        text = format('%s (%s)', pod.name.green, pod.license)
        text << format("\n\tWatchers: %5s, Forks: %5s, Last Pushed: %s",
                       pod.github_watchers || '-',
                       pod.github_forks || '-',
                       pod.github_last_activity.try(:yellow) || '-',
                       ) if @info
        text << "\n\t#{pod.summary}\n"
      end

      def pick_open_url(spec)
        url = spec.homepage
        if @spec && url =~ %r{^https?://github.com/}
          format('%s/tree/master/%s.podspec', url, spec.name)
        elsif @release && url =~ %r{^https?://github.com/}
          format('%s/releases', url)
        else
          url
        end
      end
    end
  end
end
