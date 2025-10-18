module TaoPress
  class Serializer
    def self.inherited(base)
      class << base
        def serializers
          @serializers ||= {}
        end

        def serialize(key, &block)
          if block
            serializers[key] = block
          else
            serializers[key] = ->(obj, _context) { obj.public_send(key) }
          end
        end
      end
      super
    end

    def to_proc
      method(:call).to_proc
    end
  end
end
