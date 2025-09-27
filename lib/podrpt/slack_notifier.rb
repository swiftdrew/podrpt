# lib/podrpt/slack_notifier.rb

module Podrpt
  class SlackNotifier
    def self.notify(webhook_url, report_text, dry_run: false)
      if dry_run
        puts "\n--- SLACK NOTIFICATION DRY RUN ---"
        puts "Target URL: #{webhook_url || 'Nenhuma URL fornecida'}"
        puts "--- Payload ---"
        puts report_text
        puts "----------------------------------"
        puts "[podrpt] Dry run concluído. Nenhuma notificação foi enviada."
        return
      end

      unless webhook_url && !webhook_url.empty?
        puts "[podrpt] ERRO: URL do Slack não fornecida. Saindo."
        exit 1
      end
      
      puts "[podrpt] Enviando relatório para o Slack..."
      headers = { 'Content-Type' => 'application/json' }
      payload = { text: "```\n#{report_text}\n```" }.to_json
      
      begin
        response = HTTParty.post(webhook_url, body: payload, headers: headers)
        if response.success?
          puts "[podrpt] Relatório enviado com sucesso!"
        else
          puts "[podrpt] ERRO ao enviar para o Slack. Status: #{response.code}, Resposta: #{response.body}"
          exit 1
        end
      rescue => e
        puts "[podrpt] ERRO de conexão ao enviar para o Slack: #{e.message}"
        exit 1
      end
    end
  end
end