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

## Usage

Instantiate ZenConfig with a configuration hash :

    config_hash = { :foo => "foo value" }
    MyConfig = ZenConfig.new config_hash
    MyConfig.foo
     => "foo value"

By default, ZenConfig is read only :

    MyConfig.foo = "bar value"
    NoMethodError: undefined method `foo=' for #<ZenConfig:0x00000002ee52f8>

But changes can be allowed on build time :

    MyConfig = ZenConfig.new config_hash, true
    MyConfig.foo = "bar value"
     => "bar value"
    MyConfig.foo
     => "bar value"

Then the object can be locked to read only again :

    MyConfig.read_only
    MyConfig.read_only?
     => true
    MyConfig.foo = "foo value"
    NoMethodError: undefined method `foo=' for #<ZenConfig:0x00000002ee52f8>

And there's no way to unlock write.
This guarantees that ZenConfig data hasn't been altered since read-only lock has been set.
You should not use unlocked ZenConfig in your application code, since you don't know when and where it has been modified.
Dynamic persistent writes functions will come in future versions.

Sub configurations can be nested (if ZenConfig object is not locked) :

    MyConfig.new :bar
    MyConfig.bar.baz = "baz value"

Nested configurations are ZenConfigs. This allow accessing configuration on a specific context :

    MyBarConfig = MyConfig.bar
    MyBarConfig.class
     => ZenConfig
    MyBarConfig.baz
     => "baz value"

Nested ZenConfigs can access their parent :

    MyBarConfig.parent.foo
     => "bar value"

Of course, root ZenConfig has no parent :

    MyConfig.parent
     => nil

You can check if a config key exists :

    MyConfig.foo_exists?
     => true

Count keys :

    MyConfig.count
     => 2
    MyConfig.bar.count
     => 1

ZenConfigs can be converted to hashs :

    MyConfig.to_hash
     => {:foo=>"bar value", :bar=>{:baz=>"baz value"}}

And finally, config keys can be deleted (if ZenConfig is unlocked) :

    MyConfig.delete :foo
    MyConfig.to_hash
     => {:bar=>{:baz=>"baz value"}}

Note : ZenConfig methods are reserved words that can not be used as config keys.
They'll probably be renamed with a leading underscore in future versions.

## Goals

1. Provide hierarchical configuration objects => Done!
2. Bring a read-only lock mode to guarantee config values haven't been modified => Done!
3. Allow config file loading.
4. Allow config file writing.
5. Provide full unit tests.

## Known bugs

- Nested hashs raise an error on init
- Merging doesn't always work