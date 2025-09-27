module Podrpt
  class LockfileAnalyzer
    def initialize(project_dir)
      lockfile_path = File.join(project_dir, 'Podfile.lock')
      raise "ERRO: #{lockfile_path} não encontrado." unless File.exist?(lockfile_path)
      @lockfile = Pod::Lockfile.from_file(Pathname.new(lockfile_path))
    end

    def pod_versions
      pod_versions_map = {}
      @lockfile.pod_names.each do |pod_name|
        root_name = Pod::Specification.root_name(pod_name)
        pod_versions_map[root_name] ||= @lockfile.version(pod_name).to_s
      end
      pod_versions_map
    end

    def classify_pods
      lockfile_hash = @lockfile.to_hash
      all_pods = (@lockfile.pod_names || []).map { |n| Pod::Specification.root_name(n) }.to_set
      git_pods = Set.new
      dev_pods = Set.new
      (lockfile_hash['EXTERNAL SOURCES'] || {}).each do |name, details|
        root_name = Pod::Specification.root_name(name)
        git_pods.add(root_name) if details.key?(:git)
        dev_pods.add(root_name) if details.key?(:path)
      end
      spec_repo_pods = all_pods - git_pods - dev_pods
      { spec_repo: spec_repo_pods, git_source: git_pods, dev_path: dev_pods }
    end
  end
end