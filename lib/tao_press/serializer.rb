module TaoPress
  class Serializer
    def self.inherited(base)
      class << base
        def serializers
          @serializers ||= {}
        end

        def serialize(key, &block)
          if block
            serializers[key] = ->(obj) { block.(obj) }
          else
            serializers[key] = ->(obj) { obj.public_send(key) }
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
