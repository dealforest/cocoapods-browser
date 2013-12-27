module Pod
  class Command
    class Browser < Command
      self.summary = 'Open the homepage'

      self.description = <<-DESC
        Opens the homepage on browser.
      DESC

      self.arguments = '[QUERY]'

      def initialize(argv)
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
                UI.puts("Opening #{url}")
                open!(url)
                opened = true
              else
                UI.warn "Skipping `#{set.name}` because the homepage not found."
              end
            rescue DSLError
              UI.warn "Skipping `#{set.name}` because the podspec contains errors."
            end
          end
          UI.warn "The query(`#{query}`) not found pod." unless opened
        end
      end
    end
  end
end
