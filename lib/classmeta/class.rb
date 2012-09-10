require 'securerandom' 

module Classmeta
  module ClassMethods
    # Generates a unique classname and calls named_meta with provided parameters.
    # e.g. has_many :employees, class_name: MyModel.meta(:ref, attrs: [:name, :status], special_column: 'my_column').name
    def meta(*args)
      puts "#{self.name}.meta called with args=#{args.inspect}" if Classmeta::Options.debugging?
      options = args.extract_options! # separates options hash and leaves one or more transform names
      self.named_meta("#{self}#{SecureRandom.uuid.gsub('-','')}", args, options)
    end
    alias_method :m, :meta

    # Define a new class with specified classname using the specified transformer(s) and options.
    # e.g. has_many :employees, class_name: MyModel.named_meta(MyNewModel, :transformer_key, {attrs: [:name, :status], special_column: 'my_column'}).name
    # e.g. has_many :employees, class_name: MyModel.named_meta(MyNewModel, [:transformer_key1, :transformer_key2], {attrs: [:name, :status], special_column: 'my_column'}).name
    def named_meta(new_classname, transformer_key_or_keys = [], options = {})
      # handle unspecified transformer_key_or_keys
      if transformer_key_or_keys.is_a?(Hash) && options.is_a?(Hash) && options.size == 0
        options = transformer_key_or_keys
        transformer_key_or_keys = []
      end

      if Classmeta::Options.debugging?
        puts "#{self.name}.named_meta called with new_classname=#{new_classname.inspect}, transformer_key_or_keys=#{transformer_key_or_keys.inspect}, options=#{options.inspect}"
        puts "#{self.name} calling #{self.name}.dup" if Classmeta::Options.debugging?
      end
      new_class = self.dup
      puts "#{self.name} defining function called 'name' on new class #{new_class} to return #{new_classname.inspect}" if Classmeta::Options.debugging?
      new_class.instance_eval("def name; #{new_classname.inspect}; end")
      transformer_keys = Array.wrap(transformer_key_or_keys).flatten
      if transformer_keys && transformer_keys.size > 0
        puts "#{self.name} using Transformers #{transformer_keys.inspect} to transform class #{new_classname.inspect}" if Classmeta::Options.debugging?
        transformer_keys.each do |transformer_key|
          transformer = Classmeta::Options.get_transformer(transformer)
          if transformer
            puts "#{self.name} calling #{transformer.name}.transform(#{new_class}, #{self}, #{options.inspect})" if Classmeta::Options.debugging?
            transformer.transform(new_class, self, options)
          else
            Classmeta::Options.output if Classmeta::Options.debugging?
            raise "Classmeta::Options needs a :transformers hash that contains a key called #{transformer_key.inspect}"
          end
        end
      else
        transformer = Classmeta::Options.get_transformer(:default)
        puts "Classmeta::Options's :default transformer = #{transformer.inspect}" if Classmeta::Options.debugging?
        if transformer
          puts "#{self.name} calling #{transformer.name}.transform(#{new_class}, #{self}, #{options.inspect})" if Classmeta::Options.debugging?
          transformer.transform(new_class, self, options)
        end
      end
      puts "#{self.name} registering #{name} so class lookup works in Rails" if Classmeta::Options.debugging?
      Classmeta::ClassRegistry.register(new_classname, [self, transformer_key_or_keys, options])
      # TODO: use ActiveSupport::Dependencies::Registry.store(new_class) ?
      new_class
    end
    alias_method :n, :named_meta
  end
end
