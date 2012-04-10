require 'zen_config/version'
require 'forwardable'

class ZenConfig
  include Enumerable
  extend Forwardable

  def_delegators :@data, :each, :<<

  def initialize hash, allow_modifications = false
    @allow_modifications = true
    @loaded_section = nil
    @index = 0
    @data = {}

    load_hash hash

    if allow_modifications
      read_only
    end
  end

  # Keys

  def count
    @count
  end

  def delete key
    if @allow_modifications
      backup = @data[key]
      @data.delete key
      update_count
      return backup
    end
  end

  def exists? key
    @data.has_key? key
  end

  def get name, default = nil
    result = default

    if @data.has_key? name
      result = @data[name]
    end

    return result
  end

  def new key, force = false
    key = key.to_sym

    if @allow_modifications
      if (!exists? key) || force
        @data[key] = ZenConfig.new({}, true)
        set_key_parent key
      else
        raise "'#{key}' key already exists."
      end
    end
  end

  def set key, value
    if @allow_modifications
      if value.is_a? Hash
        @data[key] = self.new value, true
      else
        @data[key] = value
      end

      set_key_parent key
      update_count

      return value
    end
  end

  #Global

  def load_hash hash
    if @allow_modifications
      hash.each do |key, value|
        puts key.to_s + " : " + value.to_s
        key = key.to_sym

        if value.is_a? Hash
          @data[key] = ZenConfig.new value, @allow_modifications
        else
          @data[key] = value
        end

        set_key_parent key
      end

      update_count
    end
  end

  def merge merge
    raise "Merged configuration must be a ZenConfig" unless merge.kind_of? ZenConfig

    merge.each do |key, value|
      if @data.has_key? key
        if (value.kind_of? ZenConfig) && (@data[key].kind_of? ZenConfig)
          @data[key] = @data[key].merge(ZenConfig.new value.to_hash, !read_only?)
        else
          @data[key] = value
        end
      else
        if value.kind_of? ZenConfig
          @data[key] = ZenConfig.new value.to_hash, read_only?
        else
          @data[key] = value
        end
      end

      set_key_parent key
    end

    return self
  end

  def method_missing method, *args
    value = args.first

    # Checks if a key exists
    if /\A(.*)_exists\?\Z/.match method
      exists? $1

    # Delete a key
    elsif /\Adelete_(.*)\Z/.match method
      delete $1 if exists? $1

    # Writes a key value
    elsif (method[-1] == '=') && @allow_modifications
      key = method[0..-2].to_sym
      set key, value

    # Reads a key value
    elsif (args.count == 0)
      get method

    # Unknown method
    else
      super
    end
  end

  def read_only
    @allow_modifications = false
    @data.each do |key, value|
      if value.kind_of? ZenConfig
        value.read_only
      end
    end
  end

  def read_only?
    !@allow_modifications
  end

  def to_hash
    hash = {}
    @data.each do |key, value|
      if value.kind_of? ZenConfig
        hash[key] = value.to_hash
      else
        hash[key] = value
      end
    end

    return hash
  end

  # Parent

  def parent
    return @parent
  end

  def set_key_parent key
    if @data[key].kind_of? ZenConfig
      @data[key].set_parent self
    end
  end

  def set_parent parent
    if parent.kind_of? ZenConfig
      @parent = parent
    else
      raise "Parent must be a ZenConfig"
    end
  end

  private

  def update_count
    @count = @data.count
  end
end
