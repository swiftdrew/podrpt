# lib/podrpt/configuration.rb
require 'yaml'

module Podrpt
  class Configuration
    CONFIG_FILE = '.podrpt.yml'.freeze
    RISK_FILE = 'PodsRisk.yaml'.freeze
    ALLOWLIST_FILE = 'PodsAllowlist.yaml'.freeze

    def self.save_slack_url(url)
      config = File.exist?(CONFIG_FILE) ? YAML.load_file(CONFIG_FILE) || {} : {}
      config['slack_webhook_url'] = url
      File.write(CONFIG_FILE, config.to_yaml)
      puts "✅ URL do Slack salva em #{CONFIG_FILE}"
    end

    def self.load_slack_url
      return nil unless File.exist?(CONFIG_FILE)
      YAML.load_file(CONFIG_FILE)['slack_webhook_url']
    end

    def self.create_risk_file(pod_names: [])
      return if File.exist?(RISK_FILE)

      bands_config = { 'green_max' => 400, 'yellow_max' => 700 }
      default_config = { 'owners' => [], 'risk' => 500 }
      
      pods_hash = {}
      if pod_names.empty?
        puts "⚠️ Nenhum pod encontrado para pré-popular. Criando arquivo de risco com um exemplo."
        pods_hash['Firebase'] = { 'owners' => ['core-team'], 'risk' => 100 }
      else
        pod_names.sort_by(&:downcase).each do |name|
          pods_hash[name] = YAML.load(default_config.to_yaml)
        end
      end

      final_structure = {
        'bands' => bands_config,
        'default' => default_config,
        'pods' => pods_hash
      }

      File.write(RISK_FILE, final_structure.to_yaml)
      puts "✅ Arquivo '#{RISK_FILE}' criado e pré-populado com #{pods_hash.count} pods."
    end

    def self.create_allowlist_file(pod_names: [])
      return if File.exist?(ALLOWLIST_FILE)
      
      header = <<~YAML
        # The allowlist is used to filter transitive dependencies (sub-dependencies)
        # and focus only on the pods you manage directly in your Podfile.
        #
        # For each "group" (e.g., Firebase), only the pods listed here will appear in the report.
        # Pods that don't belong to any group (e.g., Alamofire) will appear by default.
        #
        # Uncomment and adjust the examples below, or create your own groups.
      YAML

      example_content = {
        'allowlist' => {
          'Firebase' => ['FirebaseAnalytics', 'FirebaseCrashlytics']
        }
      }

      project_pods_comment = pod_names.sort_by(&:downcase).map { |name| "#    - #{name}" }.join("\n")
      
      final_content = header + example_content.to_yaml
      unless pod_names.empty?
        final_content += "\n# --- Pods Encontrados no seu Projeto (descomente para usar) ---\n"
        final_content += "# allowlist:\n"
        final_content += "#   MeuGrupo:\n"
        final_content += project_pods_comment
      end

      File.write(ALLOWLIST_FILE, final_content)
      puts "✅ Arquivo de exemplo '#{ALLOWLIST_FILE}' criado."
    end
  end
end