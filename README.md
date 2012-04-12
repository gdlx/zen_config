# ZenConfig

ZenConfig is an attempt to rewrite Zend Framework's Zend_Config for Ruby.

It allows easy management of configuration objects and files.

## Installation

Add this line to your application's Gemfile:

    gem 'zen_config'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zen_config

## App integration

Create your config file __config/config.yml__ :

    defaults: &defaults
      user:
        name:
          max_length: 64
      post:
        max_length: 140
    development:
      <<: defaults
    production:
      <<: defaults

Create a new initializer __config/initializers/config.rb__ :

    APP_CONFIG = ZenConfig.new(YAML::load(File.open("#{Rails.root}/config/config.yml"))[Rails.env])

Restrict config scope in your classes :

    class User
      @config = APP_CONFIG.user

      validates :name, :length => { :maximum => @config.name.max_length }

      [...]

    end

## Usage

###Instantiate ZenConfig with a configuration hash :

    config_hash = { :foo => "foo value", :bar => { :baz => "baz value" } }
    MyConfig = ZenConfig.new config_hash
    MyConfig.foo
     => "foo value"
    MyConfig.bar.baz
     => "baz value"

###By default, ZenConfig is read only :

    MyConfig.foo = "bar value"
    NoMethodError: undefined method `foo=' for #<ZenConfig:0x00000002ee52f8>

###But changes can be allowed on build time :

    MyConfig = ZenConfig.new config_hash, true
    MyConfig.foo = "new foo value"
     => "new foo value"
    MyConfig.foo
     => "new foo value"
     
###Then the object can be locked to read only again :

    MyConfig.read_only
    MyConfig.read_only?
     => true
    MyConfig.foo = "foo value"
    NoMethodError: undefined method `foo=' for #<ZenConfig:0x00000002ee52f8>

__And there's no way to unlock write.__

This guarantees that ZenConfig data hasn't been altered since read-only lock has been set.
You should not use unlocked ZenConfig in your application code, since you don't know when and where it has been modified.
Dynamic persistent writes functions will come in future versions.

###Sub configurations can be nested (if ZenConfig is unlocked) :

    MyConfig.new :bar
    MyConfig.bar.baz = "baz value"

###Nested configurations are ZenConfigs :

    MyBarConfig = MyConfig.bar
    MyBarConfig.class
     => ZenConfig
    MyBarConfig.baz
     => "baz value"
     
This allow accessing configuration on a specific context.

###Nested ZenConfigs can access their parent :

    MyBarConfig.parent.foo
     => "bar value"

###Of course, root ZenConfig has no parent :

    MyConfig.parent
     => nil

###ZenConfigs can be converted to hashs :

    MyConfig.to_hash
     => {:foo=>"new foo value", :bar=>{:baz=>"baz value"}}

###ZenConfigs subkeys can be parsed :

	MyConfig.each do |key, value|
	  puts key.to_s + ":" + value.class.to_s
	end
	foo:String
	bar:ZenConfig
	 => {:foo=>"foo value", :bar=>{:baz=>"baz value"}}

###Counted :

    MyConfig.count
     => 2
    MyConfig.bar.count
     => 1

###Checked :

    MyConfig.exists? :bar
     => true
     
or

    MyConfig.bar_exists?
     => true

###Deleted (if ZenConfig is unlocked) :

    MyConfig.delete :bar
    MyConfig.to_hash
     => {:foo=>"new foo value"}
     
or

    MyConfig.delete_bar
    MyConfig.to_hash
     => {:foo=>"new foo value"}

## Important note on reserved words :

Some words are reserved by Ruby or ZenConfig (public methods or attributes).

The best practice is to avoid using one of these reserved words as keys in your config files, but you can call them by adding an underscore in front of the key.

Using these reserved words can result in strange behaviors :

	MyConfig = ZenConfig.new({ :reject => { :default => 10 } })
	[...]
	MyConfig.to_hash
	 => {:reject=>{:value=>"10"}}

Config is successfully loaded but :
 
	MyConfig.reject.value
	NoMethodError: undefined method `value' for #<Enumerator:0x000000026fd5b8>

Solution :
	
	MyConfig._reject.value
	 => 10

Reserved words could be reduced by making ZenConfig a BasicObject subclass, but it's not possible as ZenConfig uses Enumerable.

__Anyone knowing how to get the best of both worlds is welcome !__

## Goals

- Provide hierarchical configuration objects => Done!
- Bring a read-only lock mode to guarantee config values haven't been modified => Done!
- Allow config file loading.
- Allow config file writing.
- Provide full unit tests.

## Known bugs

- Merging doesn't always work