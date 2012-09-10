module Classmeta
  class ClassRegistry
    @@registry = {}

    def self.register(name, arr)
      puts "Classmeta::ClassRegistry registering #{name.inspect}, #{arr.inspect}" if Classmeta::Options.debugging?
      @@registry[name.to_sym] = arr
    end

    def self.get(name)
      puts "Classmeta::ClassRegistry.get called" if Classmeta::Options.debugging?
      arr = @@registry[name.to_sym]
      if arr
        # re-meta, so the class that was derived from can be reloaded
        puts "Classmeta::ClassRegistry calling #{arr[0].name}.named_meta with #{name.inspect}, #{arr[1].inspect}, #{arr[2].inspect}" if Classmeta::Options.debugging?
        arr[0].named_meta(name, arr[1], arr[2])
      else
        puts "Classmeta::ClassRegistry didn't find anything for name #{name} in Classmeta's class registry: #{@@registry.inspect}" if Classmeta::Options.debugging?
        nil
      end
    end
  end
end
