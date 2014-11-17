require 'active_support/core_ext/module/aliasing'

class KeySet < Set
  def initialize(store, store_key)
    @store     = store
    @store_key = store_key

    super(Array.wrap(@store.send(:read_entry, @store_key, {})))
  end

  def add_with_cache(value)
    add_without_cache(value)
  ensure
    store
  end

  alias_method_chain :add, :cache

  def delete_with_cache(value)
    delete_without_cache(value)
  ensure
    store
  end

  alias_method_chain :delete, :cache

  def clear_with_cache
    clear_without_cache
  ensure
    store
  end

  alias_method_chain :clear, :cache
  private
  def store
    @store.with do |connection|
      @store.send(:write_entry_without_match_support, @store_key, self.to_a, connection: connection)
    end
  end
end
