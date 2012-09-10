Classmeta for Rails 3.x+
=====

Creates new classes on the fly in Rails, optionally transform them, and have kick-ass, short association descriptions that double as class definitions. Open a ticket to add to the README if you find an inventive use that you think others would benefit from.

Lets say you wanted whitelisted attributes to be different depending which class was including it as an association.

In car, you only want the names of passengers:

    has_many :passengers, class_name: Person.meta(attrs: [:name]).name

In train, you want their seat preference:

    has_many :riders, class_name: Person.meta(attrs: [:name, :seat_preference]).name

So, include the gem in Gemfile and bundle install:

    gem 'classmeta'

Add a transformer somewhere in the load path, e.g. to transform models, maybe you could put this in `app/models/default_transformer.rb` which would ensure the `table_name`, `primary_key` are set to be the same as the original class, and it would also allow the `_accessible_attributes` whitelist to be overriden with `:attrs` value in the options hash:

    class DefaultTransformer
      def transform(klass, derived_from_class, options)
        status_column = options[:status_column] || 'record_status'
        klass.class_eval "self.table_name = #{derived_from_class.table_name.inspect}"
        klass.class_eval "self.primary_key = #{derived_from_class.primary_key.inspect}"
        klass.class_eval "self._accessible_attributes[:default] = #{options[:attrs].inspect}" if options[:attrs]
      end
    end

And add this to environment.rb:

    Classmeta::Options.configure({
      :transformers => {
        :default => DefaultTransformer
      }
    })

Now magically car passengers have their accessible attributes set to `:name` and train riders to `[:name, :seat_preference]`!

### How?

Hooking into Rails' load_missing_constant, duping the original class, and doing stuff to it in the transform.

Works with class reloading or caching.

### Why?

It's useful if you have a number of classes, like models, that just differ by a little bit and module includes just aren't solving the problem of doubling, tripling, etc. the number of files you are having to create just to represent new classes.

### Unnamed metas

This generates a new class named "MyModel<some unique random string>" sending that class and nil options hash to the transform function of transformer associated with the :default key in Classmeta::Options if there is one, otherwise it will just generate a new model class with the same behavior as the old one and not transform it:

    MyModel.meta

This generates a new class named "MyModel<some unique random string>" sending that class and options hash `attrs: [:name, :status], special_column: 'my_column'` to the transform function of transformer associated with the :default key in Classmeta::Options if there is one, otherwise it will just generate a new model class with the same behavior as the old one and not transform it:

    MyModel.meta(attrs: [:name, :status], special_column: 'my_column')

This generates a new class named "MyModel<some unique random string>" sending that class and options hash `attrs: [:name, :status], special_column: 'my_column'` to the transform function of transformer associated with the :awesome key in Classmeta::Options:

    MyModel.meta(:awesome, attrs: [:name, :status], special_column: 'my_column')

This generates a new class named "MyModel<some unique random string>" sending that class and options hash `attrs: [:name, :status], special_column: 'my_column', somethin_else: {a: 1, b: {c: 1, d: 2}}` to the transform function of transformers associated with the :awesome and :bitchin keys in Classmeta::Options:

    MyModel.meta(:awesome, :bitchin, attrs: [:name, :status], special_column: 'my_column', somethin_else: {a: 1, b: {c: 1, d: 2}})

### Named metas

This generates a new class named "Fabular" sending that class and nil options hash to the transform function of transformer associated with the :default key in Classmeta::Options if there is one, otherwise it will just generate a new model class with the same behavior as the old one and not transform it:

    MyModel.named_meta('Fabular')

This generates a new class named "Fabular" sending that class and options hash `attrs: [:name, :status], special_column: 'my_column'` to the transform function of transformer associated with the :default key in Classmeta::Options if there is one, otherwise it will just generate a new model class with the same behavior as the old one and not transform it:

    MyModel.named_meta('Fabular', {attrs: [:name, :status], special_column: 'my_column'})

This generates a new class named "Fabular" sending that class and options hash `attrs: [:name, :status], special_column: 'my_column'` to the transform function of transformer associated with the :awesome key in Classmeta::Options:

    MyModel.named_meta('Fabular', :awesome, {attrs: [:name, :status], special_column: 'my_column'})

This generates a new class named "Fabular" sending that class and options hash `attrs: [:name, :status], special_column: 'my_column', somethin_else: {a: 1, b: {c: 1, d: 2}}` to the transform function of transformers associated with the :awesome and :bitchin keys in Classmeta::Options:

    MyModel.named_meta('Fabular', [:awesome, :bitchin], {attrs: [:name, :status], special_column: 'my_column', somethin_else: {a: 1, b: {c: 1, d: 2}}})

### 'm' and 'n' functions

Instead of `meta`, use `m`:

    MyModel.m(:awesome, :bitchin, attrs: [:name, :status], special_column: 'my_column', somethin_else: {a: 1, b: {c: 1, d: 2}})

Instead of `named_meta`, use `n`:

    MyModel.n('Fabular', [:awesome, :bitchin], {attrs: [:name, :status], special_column: 'my_column', somethin_else: {a: 1, b: {c: 1, d: 2}}})

### Try it out

Add to your Gemfile:

    gem 'classmeta'

Install it:

    bundle install

Open console:

    rails c

Try it:

    YourModel.meta(:echo)
    YourModel.meta(:echo).name
    YourModel.meta(:echo, {:say => 'Hello World!'})
    YourModel.named_meta('Fabular', :echo, {:say => 'Hello World!'})
    Fabular.all

Note: if you define `Classmeta::Options.configure({...})`, it automatically gets rid of the echo transformer which is just for demonstration purposes. If you want to use it at runtime, you can use:

    Classmeta::Options.configure({
      :transformers => {
        :echo => Classmeta::Echo
      }
    })

### Just Rails?

Feel free to add off-Rails support and do a pull request.

### Compatibility Notes

Not tested with Rails 2.3. Let me know if you have any compatibility issues.

Ruby 1.9 is expected because of the way `SecureRandom` is abused for classes that aren't given a defined name via `named_meta`.

But, it should work in Ruby 1.8.x if you try adding one of the following on the load path, e.g. in `config/environment.rb`:

    class SecureRandom
      # not guaranteed to be unique
      def self.uuid
        # from http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby
        o = [('a'..'z'),('A'..'Z')].map{|i|i.to_a}.flatten
        (0..50).map{o[rand(o.length)]}.join
      end
    end

or maybe:

    class SecureRandom
      def self.uuid
        ActiveSupport::SecureRandom.uuid
      end
    end

### Troubleshooting

#### Debugging

Add `:debug => true` to the Classmeta configuration:

    Classmeta::Options.configure({
      :debug => true,
      ...
    })

#### OriginalModelName.n('NewModelName') results in (Table doesn't exist) being displayed next to model instance, or get error: 'relation "new_model_names" does not exist', etc.

If you are duplicating the model class instance and renaming the new instance with classmeta, then it still has to deal with ActiveRecord as if you defined a new model class with that name, so if the original class name didn't define table name, etc. explicitly and ActiveRecord is trying to intuit those from the classname, it still won't find them.

#### uninitialized constant (something) (NameError), etc.

Since Classmeta delegates to Rails's dependency loading, any errors you get like this:

    .../classmeta/lib/classmeta/dependencies.rb:7:in `load_missing_constant': uninitialized constant (something) (NameError)

Just means Rails couldn't find your class.

For these and other errors, pretend you are getting that from `.../activesupport/lib/activesupport/dependencies.rb`, then Google it and scratch your head until you figure out you mistyped something.

### Updating from prior versions

* v0.0.2 -> v0.1.0: breaking transform method signature change- now expects to be able to send in the derived from class: `def transform(klass, derived_from_class, options)`

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[lic]: http://github.com/garysweaver/classmeta/blob/master/LICENSE
