module Podrpt
  module VersionComparer
    def self.tokenize(version); (version || '').to_s.scan(/[A-Za-z]+|\d+/).map { |t| t.match?(/\d+/) ? t.to_i : t.downcase }; end
    def self.compare(a, b)
      ta, tb = tokenize(a), tokenize(b)
      [ta.length, tb.length].max.times do |i|
        va, vb = ta[i] || 0, tb[i] || 0
        if va.is_a?(vb.class)
          next if va == vb
          return va > vb ? 1 : -1
        else
          return va.is_a?(Integer) ? 1 : -1
        end
      end
      0
    end
  end
end