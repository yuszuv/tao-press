# frozen_string_literal: true
require "php_serialize"

require "dry/transformer"

module Mappers
  class NewsMapper < TaoPress::Mapper
    include Import[
      "repositories.file_repo"
    ]

    container.tap do |t|
      t.register(:parse_heading_level) do |str|
        str.to_s.length > 0 ? str.to_s[/\d{1,}/].to_i : nil
      end

      t.register(:reject_empty_headline) do |data|
        data[:text].to_s.length > 0 ? data : nil
      end

      t.register(:to_meta, (
        t(:unserialize)
          .>> t(:deep_symbolize_keys)
          .>> t(:unwrap, :de, [:title, :alt, :link, :caption])
          .>> t(:accept_keys!, [:title, :alt, :link, :caption])
          .>> t(:constructor_inject, Entities::Content::Gallery::Image::Meta)
      ))

      t.register(
        :to_headline,
        (t[:unserialize]
          .>> t[:deep_symbolize_keys]
          .>> t[:map_value, :unit, t[:parse_heading_level]]
          .>> t[:rename_keys, value: :text, unit: :level]
          .>> t[:reject_empty_headline]
        )
      )

      t.register :sort do |value, key|
        value.sort_by{ _1[key] }
      end
    end

    define! do
      symbolize_keys

      map_value :content do
        sort :sorting
        map_array do
          content_guard :text do
            map_value :headline do
              to_headline
            end
            accept_keys! Entities::Content::Text.attribute_names
            constructor_inject Entities::Content::Text
          end
          content_guard :gallery do
            map_value :headline do
              to_headline
            end
            rename_keys files: :images
            accept_keys Entities::Content::Gallery.attribute_names
            map_value :images do
              map_array do
                map_value :meta do
                  to_meta
                end
              end
            end
            constructor_inject Entities::Content::Gallery
          end
          content_guard :download do
            map_value :headline do
              to_headline
            end
            accept_keys! Entities::Content::Download.attribute_names
            constructor_inject Entities::Content::Download
          end
          content_guard :youtube do
            rename_keys youtube: :youtube_id
            map_value :headline do
              to_headline
            end
            accept_keys Entities::Content::YouTube.attribute_names
            constructor_inject Entities::Content::YouTube
          end
          content_guard :image do
            map_value :headline do
              to_headline
            end
            accept_keys Entities::Content::Image.attribute_names
            constructor_inject Entities::Content::Image
          end
        end
      end

      map_value :author do
        constructor_inject Entities::Author
      end

      map_value :file do
        guard ->{ !_1.nil? } do
          accept_keys Entities::Content::File.attribute_names
          constructor_inject Entities::Content::File
        end
      end

      map_value :teaser, :to_s.to_proc
      map_value :time, ->(int) { Time.at(int).to_datetime }

      rename_keys headline: :title,
        teaser: :excerpt,
        time: :published_at

      slugify

      accept_keys Entities::News.attribute_names
      constructor_inject Entities::News
    end
  end
end
