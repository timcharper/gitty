class Symbol
  unless method_defined?(:to_proc)
    def to_proc
      proc { |obj, *args| obj.send(self, *args) }
    end
  end
end

class Object
  unless method_defined?(:tap)
    def tap
      yield self
      self
    end
  end
end