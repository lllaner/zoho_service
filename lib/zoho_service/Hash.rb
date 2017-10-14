class Hash
  def deep_symbolize
    symbolize_keys.map { |k, v| [k, Hash === v ? v.deep_symbolize : v.to_s] }.to_h
  end

  def deep_include?(other)
    self.deep_merge(other) == self
  end
end
