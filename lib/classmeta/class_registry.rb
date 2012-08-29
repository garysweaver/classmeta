module Classmeta
  class ClassRegistry
    @@registry = {}

    def self.register(name, arr)
      @@registry[name.to_sym] = arr
    end

    def self.get(name)      
      arr = @@registry[name.to_sym]
      if arr
        # re-meta, so the class that was derived from can be reloaded
        arr[0].meta(arr[1])
      else
        puts "Didn't find anything for name #{name} in Classmeta's class registry: #{@@registry.inspect}"
        nil
      end
    end
  end
end
