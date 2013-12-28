module Pod
  class Command
    class Browser < Command
      self.summary = 'Open the homepage'

      self.description = <<-DESC
        Opens the homepage on browser.
      DESC

      self.arguments = '[QUERY]'

      def self.options
        [
          '--spec', 'Open the podspec on the browser. github.com/tree/master/[PODNAME].podspec',
        ].concat(super)
      end

      def initialize(argv)
        @spec  = argv.flag?('spec')
        @query = argv.arguments! unless argv.arguments.empty?
        super
      end

      def validate!
        super
        help! "A search query is required." unless @query
      end

      extend Executable
      executable :open

      def run
        @query.each do |query|
          opened = false
          sets   = SourcesManager.search_by_name(query.strip, false)
          statistics_provider = Config.instance.spec_statistics_provider
          sets.each do |set|
            begin
              pod = Specification::Set::Presenter.new(set, statistics_provider)
              next if query != pod.name

              if url = pod.homepage
                if @spec && url =~ %r|^https?://github.com/|
                  url << "/tree/master/#{pod.name}.podspec"
                else
                  UI.warn "Skipping `#{pod.name}` because the homgepage is only `github.com`."
                  next
                end
                UI.puts("Opening #{url}")
                open!(url)
                opened = true
              else
                UI.warn "Skipping `#{pod.name}` because the homepage not found."
              end
            rescue DSLError
              UI.warn "Skipping `#{pod.name}` because the podspec contains errors."
            end
          end
          UI.warn "The query(`#{query}`) not found pod." unless opened
        end
      end
    end
  end
end
