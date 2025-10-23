# frozen_string_literal: true
require "csv"

module Commands
  class ExportNews < TaoPress::Operation
    REGEXP = /{{file::([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})(?:\|(?:urlattr|attr|absolute))?}}/

    include Import[
      "logger",
      "db",
      "mappers.news_mapper",
      "repositories.author_repo",
      "repositories.content_repo",
      "repositories.file_repo",
      "repositories.news_repo",
      "serializers.wordpress_serializer",
      "serializers.markdown_serializer",
      "services.tag_extractor",
      "csv_writer",
      "settings"
    ]

    include Dry::Monads[:list]
    include Dry::Monads[:result]
    include Dry::Monads[:maybe]

    def call(csv_path:, markdown_path:, limit: nil)
      news_data = step fetch_news_items(limit:)

      # TODO: return correct failures (i.e. struct data)
      news, failures = step map_to_news(news_data)

      # Extract tags for successful news items
      tagged_news = step extract_tags(news)

      csv_file = step persist_csv(csv_path, tagged_news)
      markdown_dir = step persist_markdown(markdown_path, tagged_news)

      result = {
        processed_count: tagged_news.count,
        failures: failures,
        csv_file: csv_file.path,
        markdown_dir: markdown_dir
      }

      result
    end

    private

    def extract_uuids(str)
      str.scan(REGEXP).map(&:first)
    end

    def fetch_news_items(limit:)
      Try[Application::Error] do
        news_repo.listing(limit:).map do |n|
          # putting things from the db together before processing
          content = content_repo.for_news(n[:id]).map do |ce|
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

          author = author_repo.find(n[:author])

          blobs = Transformations.unserialize(n[:enclosure])
          file = file_repo.find_by_bin(blobs.first)


          { **n, content:, author:, file: }
        end
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

    def extract_tags(news)
      Try[Application::Error] do
        news.map do |news_item|
          tags = tag_extractor.(news_item)
          news_item.with(tags: tags)
        end
      end.to_result
    end

    def persist_csv(output_path, news)
      Success(
        List[*news]
          .fmap(&:to_maybe)
          .collect
      ).bind do |list|
          Try[Application::Error] do
            wordpress_serializer.(output_path, list)
          end.to_result
        end
    end

    def persist_markdown(output_dir, news)
      Success(
        List[*news]
          .fmap(&:to_maybe)
          .collect
      ).bind do |list|
          Try[Application::Error] do
            markdown_serializer.(output_dir, list)
          end.to_result
        end
    end
  end
end
