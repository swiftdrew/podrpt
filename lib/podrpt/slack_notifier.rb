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
        puts "Dry run completed. No notification was sent."
        return
      end

      unless webhook_url && !webhook_url.empty?
        puts "ERRO: Slack URL not provided. Logging out."
        exit 1
      end
      
      puts "Sending report to Slack..."
      headers = { 'Content-Type' => 'application/json' }
      payload = { text: "```\n#{report_text}\n```" }.to_json
      
      begin
        response = HTTParty.post(webhook_url, body: payload, headers: headers)
        if response.success?
          puts "Report sent successfully!"
        else
          puts "ERROR sending to Slack. Status: #{response.code}, Response: #{response.body}"
          exit 1
        end
      rescue => e
        puts "Connection ERROR when sending to Slack: #{e.message}"
        exit 1
      end
    end
  end
end