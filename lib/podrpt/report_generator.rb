module Podrpt
  class ReportGenerator
    def initialize(pods_analysis, options)
      @pods = pods_analysis
      @options = options
    end

    def build_report_text
      outdated_count = @pods.count { |p| is_outdated?(p.current_version, p.latest_version) }
      total_pods_in_report = @options.total_pods_count 
      header = "_Generated: #{Time.now.utc.iso8601}_\n" \
               "_Outdated: #{outdated_count}/#{total_pods_in_report}_"
      
      h_pod, h_ver, h_risk, h_owners = "Pod", "Versions", "Risk", "Owners"
      pod_names = @pods.map(&:name); versions = @pods.map { |p| versions_cell(p) }; risks = @pods.map { |p| risk_cell(p) }; owners = @pods.map { |p| p.owners.empty? ? "—" : p.owners.join(', ') }
      w_pod = [h_pod.length, pod_names.map(&:length).max || 0].max; w_ver = [h_ver.length, versions.map(&:length).max || 0].max; w_risk = [h_risk.length, risks.map(&:length).max || 0].max; w_owners = [h_owners.length, owners.map(&:length).max || 0].max
      
      row_formatter = ->(c1, c2, c3, c4) { "| #{c1.ljust(w_pod)} | #{c2.ljust(w_ver)} | #{c3.rjust(w_risk)} | #{c4.ljust(w_owners)} |" }
      
      lines = [header, ""]; lines << row_formatter.call(h_pod, h_ver, h_risk, h_owners)
      sep_pod = ":-" + ("-" * (w_pod - 1)); sep_ver = ":-" + ("-" * (w_ver - 1)); sep_risk = ("-" * (w_risk - 1)) + ":"; sep_owners = ":-" + ("-" * (w_owners - 1))
      lines << "|#{sep_pod}|#{sep_ver}|#{sep_risk}|#{sep_owners}|"
      @pods.each_with_index { |_, i| lines << row_formatter.call(pod_names[i], versions[i], risks[i], owners[i]) }
      
      lines.join("\n")
    end

    private

    def is_outdated?(current, latest); latest && !latest.empty? && Podrpt::VersionComparer.compare(latest, current) > 0; end
    def versions_cell(pod); current, latest = pod.current_version, pod.latest_version; return "#{current} (latest unknown)" if latest.nil? || latest.empty?; is_outdated?(current, latest) ? "#{current} -> #{latest}" : "#{current} (latest)"; end
    def risk_cell(pod); "#{pod.risk} #{risk_emoji(pod.risk)}"; end
    def risk_emoji(risk_value); return "🟢" if risk_value.nil?; case risk_value; when ...401 then "🟢"; when 401..700 then "🟡"; else "🔴"; end; end
  end
end