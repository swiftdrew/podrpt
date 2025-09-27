# lib/podrpt/models.rb

module Podrpt
  Options = Struct.new(
    :project_dir, :risk_yaml, :allowlist_yaml, :trunk_workers,
    :only_outdated, :sync_risk_yaml, :total_pods_count, :slack_webhook_url,
    :dry_run,
    keyword_init: true
  )
  PodAnalysis = Struct.new(
    :name, :current_version, :latest_version,
    :risk, :owners, keyword_init: true
  )
end