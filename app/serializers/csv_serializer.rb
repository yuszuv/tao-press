module Serializers
  class CSVSerializer
    HEADERS = %i[
      title
      subheadline
      excerpt
    ].freeze

    OPTS = {
      write_headers: true,
      headers: HEADERS,
      force_quotes: true
    }.freeze

    include Import['csv_writer']

    def call(path, news)
      csv_file = csv_writer.(path:, **OPTS) do |f|
        news
          .map{ _1.to_h.values_at(*HEADERS) }
          .each { |n| f << n }
      end

      { file: csv_file }
    end
  end
end
