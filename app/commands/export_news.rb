# frozen_string_literal: true
require "csv"
require "php_serialize"

module Commands
  class ExportNews < TaoPress::Operation
    include Import[
      "logger",
      "db",
      "repositories.author_repo",
      "repositories.content_repo",
      "repositories.file_repo",
      "repositories.news_repo",
      "mappers.post_mapper",
      "serializers.wordpress_serializer",
      "csv_writer",
      "settings"
    ]

    include Dry::Monads[:try]

    def call
      news_data = step fetch_news_items

      news = news_data.map(&post_mapper)

      result = step persist(news)

      Success(result)
    end

    private

    def fetch_news_items
      Try[Application::Error] do
        news_repo
          .listing
          .map(&add_content)
          .map(&add_author)
          .map(&add_file)
          .tap { logger.info("Fetched #{_1.count} news items") }
      end
        .to_result
        .alt_map { [_1.key, _1.e] }
    end

    def persist(news)
      Try do
        output_path = settings.csv_output_path
        results = { count: 0, items: [] }

        CSVWriter.open(output_path) do |csv|
          news
            .map(&wordpress_serializer)
            .reduce(results, &row_reducer(csv))
            .tap { csv.close }
            .tap { logger.info("CSV file closed successfully") }
        end

        results
      end
        .to_result
        .alt_map { [:io, _1] }
    end

    def add_content
      ->(news) {
        news.merge(
          content: content_repo.for_news(news[:id]),
        )
      }
    end

    def add_author
      ->(news) {
        news.merge(
          author: author_repo.find(news[:author]),
        )
      }
    end

    def add_file
      ->(news) {
        news.merge(
          file: file_repo.find(
            news[:enclosure].then(&method(:extract_uuids)).first
          )
        )
      }
    end

    def row_reducer(csv)
      -> (res, row) {
        csv << row
        # arr << csv_writer.(csv, row)
        res[:count] += 1
        res[:items] << row.first
        res
      }
    end

    def extract_uuids(blob)
      blob ? PHP.unserialize(blob) : []
    end

    # def process_and_export_news(csv, news_list)
    #   processed_count = 0
    #   errors = []
    #
    #   news_list.each do |news|
    #     result = process_single_news(news)
    #
    #     case result
    #     when Success
    #       csv_writer.call(csv, result.value!)
    #       processed_count += 1
    #     when Failure
    #       error_type, error_msg = result.failure
    #       errors << { news_id: news[:id], error: error_type, message: error_msg }
    #       logger.warn("Failed to process news #{news[:id]}: #{error_type} - #{error_msg}")
    #     end
    #   end
    #
    #   if errors.any?
    #     logger.warn("Processed #{processed_count}/#{news_list.count} items. #{errors.count} errors occurred.")
    #   else
    #     logger.info("Successfully processed all #{processed_count} items")
    #   end
    #
    #   # Continue with partial success if at least one item was processed
    #   if processed_count > 0
    #     Success(processed_count)
    #   else
    #     Failure([:all_items_failed, errors])
    #   end
    # end
  end
end
