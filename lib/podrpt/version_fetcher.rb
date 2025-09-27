module Podrpt
  class VersionFetcher
    def initialize(options)
      @options = options
      @sources_manager = Pod::Config.instance.sources_manager
    end

    def fetch_latest_versions_in_bulk(pod_names)
      return {} if pod_names.empty?
      puts "[podrpt] Descobrindo a última versão para #{pod_names.length} pods..."
      results = Concurrent::Map.new
      pool = Concurrent::ThreadPoolExecutor.new(max_threads: @options.trunk_workers)
      pod_names.each { |name| pool.post { results[name] = find_latest_version(name) } }
      pool.shutdown
      pool.wait_for_termination
      Hash[results.each_pair.to_a]
    end

    private

    def find_latest_version(pod_name)
      set = @sources_manager.search(Pod::Dependency.new(pod_name))
      set&.highest_version.to_s
    rescue => e
      warn "[podrpt] AVISO: Falha ao buscar versão para #{pod_name}: #{e.message}"
      nil
    end
  end
end