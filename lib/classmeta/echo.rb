module Classmeta
  class Echo
    def self.transform(klazz, options)
      puts "Classmeta::Echo.transform(klazz, options) called with klazz: #{klazz.name} and options: #{options.inspect}"
    end
  end
end
