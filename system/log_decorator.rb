# frozen_string_literal: true

require "delegate"

# A decorator that adds logging capabilities to any object
# Used by the dependency injection container to add logging to registered components
class LogDecorator < SimpleDelegator
  def self.for(method_name, &block)
    -> (tgt) {
        new(tgt).tap{ _1.define_logged_method(method_name, block) }
    }
  end

  def define_logged_method(method_name, log_block)
    define_singleton_method(method_name) do |*args, **kwargs, &block|
      super(*args, **kwargs, &block).tap do |result|
        log_block.(result)
      end
    end
  end
end
