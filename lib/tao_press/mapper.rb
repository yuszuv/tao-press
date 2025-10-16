module TaoPress
  class Mapper < Dry::Transformer::Pipe
    import Dry::Transformer::ArrayTransformations
    import Dry::Transformer::ClassTransformations
    import Dry::Transformer::Conditional
    import Dry::Transformer::Coercions
    import Dry::Transformer::HashTransformations

    container.tap do |t|
      t.register :unserialize do |str|
        str ? PHP.unserialize(str) : []
      end

      t.register :slugify do |data|
        slug = data[:alias].length > 0 ?
          data[:alias].to_slug.normalize(transliterate: :german).to_s :
          data[:title].to_slug.normalize(transliterate: :german).to_s
        data.merge(slug:)
      end

      t.register(:accept_keys!) do |value, keys|
        keys.to_h { |k| [k, value.to_h[k]] }
      end

      t.register :content_guard do |value, type, fn|
        next value unless value.is_a? Hash

        value[:type] == type.to_s ? fn[value] : value
      end
    end

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
