require 'securerandom' 

module Classmeta
  module ClassMethods
    # e.g. has_many :employees, class_name: MyModel.meta(:ref, attrs: [:name, :status], special_column: 'my_column').name
    def meta(*args)
      options = args.extract_options! # separates options hash and leaves one or more transform names
      self.named_meta("#{self}#{SecureRandom.uuid.gsub('-','')}", args, options)
    end

    # e.g. has_many :employees, class_name: MyModel.named_meta(MyNewModel, :ref, {attrs: [:name, :status], special_column: 'my_column'}).name
    # e.g. has_many :employees, class_name: MyModel.named_meta(MyNewModel, [:transform1, :transform2], {attrs: [:name, :status], special_column: 'my_column'}).name
    def named_meta(new_classname, transform_name_or_names, options = {})
      transforms = Array.wrap(transform_name_or_names).flatten
      #puts "#{self.name}.dup will be named: #{name}"
      new_class = self.dup
      new_class.instance_eval("def name; #{new_classname.inspect}; end")
      transforms.each do |transform|
        transformer = Classmeta::Options.get_transformer(transform)
        if transformer
          #puts "#{transformer.name}.transform(#{new_class.name}, #{options.inspect})"
          transformer.transform(new_class, options)
        else
          Classmeta::Options.output
          raise "Classmeta::Options needs a transformer mapping for #{transform.inspect}"
        end
      end
      #puts "Registering #{name} so class lookup works, if riding Rails"
      Classmeta::ClassRegistry.register(new_classname, [self, transforms])
      # TODO: figure out how to cache class in Rails: ActiveSupport::Dependencies::Registry.store(new_class)
      new_class
    end
  end
end
