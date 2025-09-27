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

    def self.create_risk_file
      return if File.exist?(RISK_FILE)
      content = {
        'default' => { 'risk' => 500, 'owners' => [] },
        'pods' => { '' => { 'risk' => 0, 'owners' => [''] } }
      }.to_yaml
      File.write(RISK_FILE, content)
      puts "✅ Arquivo de exemplo '#{RISK_FILE}' criado."
    end

    def self.create_allowlist_file
      return if File.exist?(ALLOWLIST_FILE)
      content = { 'allowlist' => { '' => [''] } }.to_yaml
      File.write(ALLOWLIST_FILE, content)
      puts "✅ Arquivo de exemplo '#{ALLOWLIST_FILE}' criado."
    end
  end
end