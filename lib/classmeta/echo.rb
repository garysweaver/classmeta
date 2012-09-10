module Classmeta
  class Echo
    def self.transform(klass, derived_from_class, options)
      puts "Classmeta::Echo.transform(klazz, options) called with klass: #{klass.name}, derived_from_class: #{derived_from_class.name}, and options: #{options.inspect}"
    end
  end
end
