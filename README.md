Classmeta for Rails 3.2+
=====

Creates new classes on the fly, to allow you to refactor common changes.

Lets say you wanted whitelisted attributes to be different depending which class was including it as an association.

In car, you only want the names of passengers:

    has_many :passengers, class_name: Person.meta(:std, attrs: [:name]).name

In train, you want their seat preference:

    has_many :riders, class_name: Person.meta(:std, attrs: [:name, :seat_preference]).name

etc. You have a ton of these for whatever reason.

So, include the gem in Gemfile and bundle install:

    gem 'classmeta'

Add a transformer somewhere in the load path like app/models/:

    class StandardTransformer
      def transform(klazz, options)
        klazz.class_eval "self._accessible_attributes[:default] = #{options[:attrs].inspect}" if options[:attrs]
      end
    end

And add this to environment.rb:

    Classmeta::Options.configure({
      :transformers => {
        :std => StandardTransformer
      }
    })

Now magically car passengers have their accessible attributes set to `:name` and train riders to `[:name, :seat_preference]`!

### How?

Hooking into Rails' load_missing_constant, duping the original class, and doing stuff to it in the transform.

Works with class reloading or caching.

### Why?

Useful if you have a number of classes, like models, in Rails 3.2+ that just differ by a little bit and module includes just aren't solving the problem of doubling, tripling, etc. the number of files you are having to create just to represent new classes.

### Just Rails?

Feel free to do a pull request and add off-Rails support.

### Quick Test!

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

### Troubleshooting

Since Classmeta delegates to Rails's dependency loading, any errors you get like this:

    .../classmeta/lib/classmeta/dependencies.rb:7:in `load_missing_constant': uninitialized constant (something) (NameError)

Just means Rails couldn't find your class.

For other errors, too, for the most part, pretend you are getting that from .../activesupport/lib/activesupport/dependencies.rb, then Google it and scratch your head until you figure out you mistyped something.

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[lic]: http://github.com/garysweaver/classmeta/blob/master/LICENSE
