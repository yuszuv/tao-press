module Serializers
  class CSVSerializer < TaoPress::Serializer
    include Import['csv_writer']

    serialize :title
    serialize :subheadline
    serialize :excerpt
    serialize :content do |obj|
      obj.content
    end

    def self.options
      {
        write_headers: true,
        headers: serializers.keys,
        force_quotes: true
      }
    end

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
  end
end
