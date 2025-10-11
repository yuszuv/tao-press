# frozen_string_literal: true
require "csv"

module Services
  class ExportNews
    include Import[
      "logger",
      "db",
      "repositories.author_repo",
      "repositories.content_repo",
      "repositories.file_repo",
      "repositories.news_repo",
      "mappers.wordpress_mapper",
      "serializers.csv_serializer",
      "csv_writer"
    ]

    def call(limit: 10, jsonl: true)
      csv = CSVWriter.build

      news_repo
        .listing
        .map(&add_content)
        .map(&add_author)
        .map(&add_file)
        .map(&wordpress_mapper)
        .map(&csv_serializer)
        .reduce(csv, &csv_writer)
        .then(&:close)
    end

    private

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
            extract_uuids(
              news[:enclosure]
            ).first
          )
        )
      }
    end

    def extract_uuids(blob)
      blob ?
        PHP.unserialize(blob) :
        []
    end
  end
end
