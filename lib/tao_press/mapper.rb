require "dry/struct"

module TaoPress
  class Mapper < Dry::Transformer::Pipe
    import Dry::Transformer::ArrayTransformations
    import Dry::Transformer::ClassTransformations
    import Dry::Transformer::Conditional
    import Dry::Transformer::Coercions
    import Dry::Transformer::HashTransformations

    import Transformations

    def call(...)
      super(...)
    rescue Dry::Struct::Error => e
      raise Application::Error.new("data in DB is not valid", :invalid_data, error: e)
    end

    def to_proc
      method(:call).to_proc
    end
  end
end
