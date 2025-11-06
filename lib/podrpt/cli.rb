# lib/podrpt/cli.rb
module Podrpt
  class CLI
    def self.start(args)
      command = args.shift || 'run'
      case command
      when 'run'
        run_reporter(args)
      when 'init'
        initialize_configuration
      when '--version', '-v'
        puts Podrpt::VERSION
      else
        puts "Comando desconhecido: '#{command}'. Use 'run' ou 'init'."
        exit 1
      end
    end

    private

    def self.initialize_configuration
      puts "🚀 Iniciando a configuração do Podrpt..."
      
      pod_names_to_configure = []
      project_dir = Dir.pwd
      lockfile_path = File.join(project_dir, 'Podfile.lock')
      
      if File.exist?(lockfile_path)
        puts "📄 `Podfile.lock` encontrado. Analisando pods para pré-popular os arquivos..."
        begin
          # Analisa o lockfile para obter a lista completa de pods externos
          analyzer = Podrpt::LockfileAnalyzer.new(project_dir)
          all_pods_versions = analyzer.pod_versions
          classified_pods = analyzer.classify_pods
          
          # Filtramos apenas para pods que não são de desenvolvimento local
          external_pods_filter = classified_pods[:spec_repo].dup
          external_pods_filter -= classified_pods[:dev_path]
          
          pods_to_configure = all_pods_versions.slice(*external_pods_filter.to_a)
          pod_names_to_configure = pods_to_configure.keys
          
        rescue => e
          puts "⚠️ Erro ao analisar o `Podfile.lock`: #{e.message}. Os arquivos serão criados com exemplos."
        end
      else
        puts "⚠️ `Podfile.lock` não encontrado. Os arquivos serão criados com exemplos."
      end

      # Cria os arquivos de configuração, passando a lista de pods encontrados
      Podrpt::Configuration.create_allowlist_file(pod_names: pod_names_to_configure)
      Podrpt::Configuration.create_risk_file(pod_names: pod_names_to_configure)
      
      puts "\nAgora, por favor, informe a URL do seu Incoming Webhook do Slack:"
      print "> "
      url = $stdin.gets.chomp
      Podrpt::Configuration.save_slack_url(url)
      puts "\nConfiguração concluída! Edite os arquivos .yaml conforme necessário e execute 'podrpt run'."
    end
    
    # O método `run_reporter` e seus auxiliares permanecem os mesmos da última versão funcional
    def self.run_reporter(args)
      options = parse_run_options(args)
      analyzer = Podrpt::LockfileAnalyzer.new(options.project_dir)
      all_pods_versions = analyzer.pod_versions
      classified_pods = analyzer.classify_pods

      initial_filter = classified_pods[:spec_repo].dup
      initial_filter -= classified_pods[:dev_path]
      current_pods = all_pods_versions.slice(*initial_filter.to_a)

      allowlist_config = load_allowlist(File.join(options.project_dir, options.allowlist_yaml))
      pods_for_report = apply_allowlist_filter(current_pods, allowlist_config)
      puts "[podrpt] Totais lock: #{all_pods_versions.size} | Pré-allowlist: #{current_pods.size} | Relatório final: #{pods_for_report.size}"
      options.total_pods_count = pods_for_report.size

      risk_config = load_risk_config(File.join(options.project_dir, options.risk_yaml))
      if options.sync_risk_yaml
        sync_risk_yaml(File.join(options.project_dir, options.risk_yaml), pods_for_report, risk_config)
      end

      version_fetcher = Podrpt::VersionFetcher.new(options)
      latest_versions = version_fetcher.fetch_latest_versions_in_bulk(pods_for_report.keys)

      final_analysis = []
      pods_for_report.sort_by { |name, _| name.downcase }.each do |name, version|
        pod_risk_info = risk_config['pods'][name] || risk_config['default']
        analysis = Podrpt::PodAnalysis.new(name: name, current_version: version, latest_version: latest_versions[name], risk: pod_risk_info['risk'], owners: pod_risk_info['owners'] || [])
        if options.only_outdated && !is_outdated(analysis.current_version, analysis.latest_version)
          next
        end
        final_analysis << analysis
      end
      
      reporter = Podrpt::ReportGenerator.new(final_analysis, options)
      report_text = reporter.build_report_text

      Podrpt::SlackNotifier.notify(options.slack_webhook_url, report_text, dry_run: options.dry_run)
    end
    
    def self.parse_run_options(args)
      options = Podrpt::Options.new(
        project_dir: Dir.pwd,
        risk_yaml: 'PodsRisk.yaml',
        allowlist_yaml: 'PodsAllowlist.yaml',
        only_outdated: true,
        trunk_workers: 8,
        slack_webhook_url: ENV['SLACK_WEBHOOK_URL'] || Podrpt::Configuration.load_slack_url,
        dry_run: false
      )
      OptionParser.new do |opts|
        opts.banner = "Usage: podrpt run [options]"
        opts.on("--project-dir DIR", "Diretório do projeto") { |v| options.project_dir = v }
        opts.on("--slack-webhook-url URL", "URL do Webhook (sobrescreve config)") { |v| options.slack_webhook_url = v }
        opts.on("--show-all", "Mostra todos os pods") { |v| options.only_outdated = false }
        opts.on("--sync-risk-yaml", "Sincroniza PodsRisk.yaml") { |v| options.sync_risk_yaml = v }
        opts.on("--dry-run", "Simula o envio para o Slack, printando o payload no terminal") { |v| options.dry_run = v }
      end.parse!(args)

      options
    end
    
    def self.load_allowlist(path); return {} unless File.exist?(path); config = YAML.load_file(path); config&.key?('allowlist') ? config['allowlist'] : {}; rescue; {}; end
    def self.apply_allowlist_filter(all_pods, allowlist_config)
      return all_pods if allowlist_config.nil? || allowlist_config.empty?
      allowed_sets = allowlist_config.transform_values(&:to_set); vendor_prefixes = allowed_sets.keys
      all_pods.select { |pod_name, _| matched_prefix = vendor_prefixes.find { |p| pod_name.start_with?(p) }; matched_prefix ? allowed_sets[matched_prefix].include?(pod_name) : true }
    end
    def self.load_risk_config(path)
      return { 'default' => { 'risk' => 500, 'owners' => [] }, 'pods' => {} } unless File.exist?(path)
      config = YAML.load_file(path) || {}; config['default'] ||= { 'risk' => 500, 'owners' => [] }; config['pods'] ||= {}; config
    end
    def self.sync_risk_yaml(path, pods, config)
      pods.keys.sort_by(&:downcase).each { |name| config['pods'][name] ||= config['default'].dup }
      File.write(path, config.to_yaml)
      puts "[podrpt] PodsRisk.yaml sincronizado com #{config['pods'].size} pods."
    end
    def self.is_outdated(current, latest); latest && !latest.empty? && Podrpt::VersionComparer.compare(latest, current) > 0; end
  end
end