module ActiveSupport
  module Dependencies
    alias_method(:load_missing_constant_classmeta_renamed, :load_missing_constant)
    undef_method(:load_missing_constant)
    def load_missing_constant(from_mod, const_name)
      #puts "Classmeta's load_missing_constant from_mod=#{from_mod} const_name=#{const_name}"
      klazz = Classmeta::ClassRegistry.get(const_name) || load_missing_constant_classmeta_renamed(from_mod, const_name)
      klazz.class_eval('extend Classmeta::ClassMethods')
    end
  end
end
