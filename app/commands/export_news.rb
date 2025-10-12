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
      "serializers.csv_serializer",
      "csv_writer",
      "settings"
    ]

    def call(path:, limit: nil)
      news_data = step fetch_news_items(limit:)

      news = step map_to_news(news_data)

      result = step persist(path, news)
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

    def map_to_news(news_data)
      Success(news_data.map(&post_mapper))
    rescue Application::Error => e
      Failure[:invalid_data, error: e, data: news_data]
    end

    def persist(output_path, news)
      # logger.info("Starting CSV export", path: output_path, count: news.count)
      Try[Application::Error] do
        results = { processed_count: 0, items: [], file: "todo" }

        file = csv_serializer.(output_path, news)

        results.merge(file:)

        results
      end
        .to_result
    rescue => e
      puts e
      puts "this should not happen"
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
