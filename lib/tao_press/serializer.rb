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

        def options
          {
            write_headers: true,
            headers: serializers.keys,
            force_quotes: true
          }
        end
      end
      super
    end

    include Import['csv_writer']

    def call(path, news)
      csv_writer.(path:, **self.class.options) do |f|
        news
          .map(&serialize)
          .each { f << _1 }

        f
      end
    rescue Errno::ENOENT
      raise Application::Error.new("Output path does not exist", :invalid_data)
    end

    def serialize
      -> (ent) { self.class.serializers.reduce([]) do |row, (_, p)|
        row << p.(ent)
      end}
    end

    def to_proc
      method(:call).to_proc
    end
  end
end
