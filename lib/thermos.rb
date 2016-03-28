require "thermos/beverage"
require "thermos/beverage_storage"
require "thermos/dependency"
require "thermos/notifier"
require "thermos/refill_job"
require "thermos/rebuild_cache_job"

module Thermos

  def self.keep_warm(key:, model:, id:, deps: [], lookup_key: nil, &block)
    fill(key: key, model: model, deps: deps, lookup_key: lookup_key, &block)
    drink(key: key, id: id)
  end

  def self.fill(key:, model:, deps: [], lookup_key: nil, &block)
    BeverageStorage.instance.add_beverage(
      Beverage.new(key: key, model: model, deps: deps, action: block, lookup_key: lookup_key)
    )
  end

  def self.drink(key:, id:)
    Rails.cache.fetch([key, id]) do
      BeverageStorage.instance.get_beverage(key).action.call(id)
    end
  end
end
