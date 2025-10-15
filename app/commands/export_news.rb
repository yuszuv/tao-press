# frozen_string_literal: true
require "csv"
require "php_serialize"

module Commands
  class ExportNews < TaoPress::Operation
    include Import[
      "logger",
      "db",
      "mappers.news_mapper",
      "repositories.author_repo",
      "repositories.content_repo",
      "repositories.file_repo",
      "repositories.news_repo",
      "serializers.csv_serializer",
      "csv_writer",
      "settings"
    ]

    include Dry::Monads[:list]
    include Dry::Monads[:result]
    include Dry::Monads[:maybe]

    def call(path:, limit: nil)
      news_data = step fetch_news_items(limit:)

      # TODO: return correct failures (i.e. struct data)
      news, failures = step map_to_news(news_data)

      file = step persist(path, news)

      result = {
        processed_count: news.count,
        failures: failures,
        file: file.path

      }
      # logger.info("Successfully persisted news data", result: result)

      Success(result)
    end

    private

    def fetch_news_items(limit:)
      Try[Application::Error] do
        news_repo
          .listing(limit:)
          .map(&add_content)
          .map(&add_author)
          .map(&add_file)
      end
        .to_result
    end

    def map_to_news(input)
      Success(
        input.map do |n|
          Try[Application::Error] {
            news_mapper.(n)
          }.to_result
        end
        .partition(&:success?)
      )
    end

    def persist(output_path, news)
      Success(
        List[*news]
          .fmap(&:to_maybe)
          .collect
      ).bind do |list|
          Try[Application::Error] do
            csv_serializer.(output_path, list)
          end.to_result
        end
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

    def extract_uuids(blob)
      blob ? PHP.unserialize(blob) : []
    end
  end
end
