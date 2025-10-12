# frozen_string_literal: true
require "dry/transformer"

module Mappers
  class PostMapper < Dry::Transformer::Pipe
    import Dry::Transformer::ClassTransformations
    import Dry::Transformer::Conditional
    import Dry::Transformer::HashTransformations

    # HREF_REGEXP = /(?<=href=")(\S+?)(?=")/
    # SRC_REGEXP = /(?<=src=")(\S+?)(?=")/

    define! do
      symbolize_keys

      map_value :teaser, :to_s.to_proc
      map_value :time, ->(int) { Time.at(int).to_datetime }
      map_value :content, ->(x) { "" }
      map_value :author do
        constructor_inject Entities::Author
      end
      map_value :file do
        guard ->{ !_1.nil? } do
          accept_keys :path
          constructor_inject Entities::File
        end
      end

      rename_keys headline: :title,
        alias: :slug,
        teaser: :excerpt,
        time: :published_at
        # enclosure: :attachment_url

      accept_keys Entities::Post.attribute_names

      constructor_inject Entities::Post
    end

    def to_proc
      method(:call).to_proc
    end

    private

    # def t(*args)
    #   HTMLLookup[*args]
    # end
    #
    # def extract_title(article)
    #   article.at_css('h1')&.text || ""
    # end
    #
    # def extract_excerpt(article)
    #   article.at_css('.layout_full > div > p')&.to_html || ""
    # end
    #
    # def extract_html(article)
    #
    #   article
    #     .css('.layout_full > div')
    #     .map(&:to_s)
    #     .join
    #     .gsub(/>\s+</,"><")
    #     .gsub(/\n/,'')
    #     .gsub(HREF_REGEXP) { |m| URI::DEFAULT_PARSER.make_regexp.match(m) ? m : URI.join(settings.base_url, m) }
    #     .gsub(SRC_REGEXP) { |m| URI::DEFAULT_PARSER.make_regexp.match(m) ? m : URI.join(settings.base_url, m) }
    # end
    #
    # def extract_image_urls(article)
    #   article
    #     .css('div .image_container a')
    #     .map{ URI.join(settings.base_url, _1["href"]).to_s }
    #     .join("||")
    # end
  end
end
