module Classmeta
  class Options
    @@options = {
      :transformers => {
        :echo => Classmeta::Echo
      }
    }

    def self.configure(hash)
      @@options = hash
    end

    def self.get_transformer(name)
      (@@options[:transformers])[name]
    end

    def self.output
      puts "Classmeta::Options=#{@@options.inspect}"
    end
  end
end
