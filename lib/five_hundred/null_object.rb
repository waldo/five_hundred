# encoding: UTF-8

module FiveHundred
  class NullObject
    def method_missing(sym, *args)
      return self
    end

    def nil?
      true
    end

    def coerce(other)
      [other, 0]
    end
  end
end