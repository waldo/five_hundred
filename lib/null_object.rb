class NullObject
  def method_missing(sym, *args)
    return self
  end

  def nil?
    true
  end
end