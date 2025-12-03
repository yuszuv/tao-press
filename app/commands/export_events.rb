# frozen_string_literal: true
require "csv"

module Commands
  class ExportEvents < TaoPress::Operation
    REGEXP = /{{file::([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})(?:\|(?:urlattr|attr|absolute))?}}/

    include Import[
      "logger",
      "db",
      "mappers.event_mapper",
      "repositories.author_repo",
      "repositories.content_repo",
      "repositories.file_repo",
      "repositories.event_repo",
      "serializers.events.wordpress_serializer",
      "serializers.events.markdown_serializer",
      "csv_writer",
      "settings"
    ]

    include Dry::Monads[:list]
    include Dry::Monads[:result]
    include Dry::Monads[:maybe]

    def call(csv_path:, markdown_path:, limit: nil)
      events_data = step fetch_events_items(limit:)

      events, failures = step map_to_events(events_data)

      csv_file = step persist_csv(csv_path, events)
      markdown_dir = step persist_markdown(markdown_path, events)

      # TODO: perhaps move to error notifier
      # failures.each do |f|
      #   fail = f.failure
      #
      #   # TODO print to STDOUT
      #   logger.warn(fail.message)
      #   logger.warn(fail.key.to_s)
      #   logger.warn(fail.error.to_s)
      # end

      result = {
        processed_count: events.count,
        failures: failures.count,
        csv_file: csv_file.path,
        markdown_dir: markdown_dir
      }

      result
    end

    private

    def extract_uuids(str)
      str.scan(REGEXP).map(&:first)
    end

    def fetch_events_items(limit:)
      Try[Application::Error] do
        event_repo.listing(limit:).map do |e|
          # putting things from the db together before processing
          content = content_repo.for_event(e[:id]).map do |ce|
            case ce[:type]
            when "text"
              files = extract_uuids(ce[:text])
                .map{ file_repo.find(_1) }

              ce.merge(files:)
            when "gallery", "bs_grid_gallery"
              blobs = Transformations.unserialize(ce[:multiSRC])
              files = blobs.map{ file_repo.find_by_bin _1 }

              ce.merge(files:)
            when "download", "image"
              file = file_repo.find_by_bin(ce[:singleSRC])

              ce.merge(file:)
            else
              ce
            end.then do |ce|
              blob = ce[:singleSRC]
              image = blob ? file_repo.find_by_bin(blob) : nil
              ce.merge(image:)
            end
          end

          author = author_repo.find(e[:author])

          blobs = Transformations.unserialize(e[:enclosure])
          file = file_repo.find_by_bin(blobs.first)

          { **e, content:, author:, file: }
        end
      end
        .to_result
    end

    def map_to_events(input)
      results = input.map do |e|
        Try[Application::Error] {
          event_mapper.(e)
        }.to_result
      end

      successes, failures = results.partition(&:success?)
      events = successes.map { |s| s.value! }

      Success([events, failures])
    end

    def persist_csv(output_path, events)
      Try[Application::Error] do
        wordpress_serializer.(output_path, events)
      end.to_result
    end

    def persist_markdown(output_dir, events)
      Try[Application::Error] do
        markdown_serializer.(output_dir, events)
      end.to_result
    end
  end
end

