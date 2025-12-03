# frozen_string_literal: true
require "dry/transformer"

module Mappers
  class EventMapper < TaoPress::Mapper
    import TaoPress::ContentTransformations

    container.tap do |t|
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
          .>> t[:reject_empty, :text]
        )
      )
    end

    define! do
      symbolize_keys

      map_value :content do
        sort :sorting
        map_array do
          map_value :image do
            guard ->(s){ !s.nil? } do
              map_value :meta do
                to_meta
              end
            end
          end
          content_guard :text do
            map_value :headline do
              to_headline
            end
            map_value :files do
              map_array do
                map_value :tstamp do
                  datetime_from_int
                end
                map_value :uuid do
                  bin_to_str
                end
                map_value :path do
                  slugify_path
                  uri_escape
                end
                rename_keys tstamp: :mtime
              end
            end
            map_value :text do
              strip_artefacts
            end
            rename_keys files: :images
            replace_contao_insert_tags
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
        guard ->(x){ !x.nil? } do
          accept_keys! Entities::Content::File.attribute_names
          constructor_inject Entities::Content::File
        end
      end

      # rename_keys startDate: :start_date, startTime: :start_time
      rename_keys tstamp: :published_at, startTime: :start_time, endTime: :end_time

      map_value :teaser, :to_s.to_proc
      map_value :published_at do
        datetime_from_int
      end
      map_value :start_time do
        datetime_from_int
      end
      map_value :end_time do
        guard ->(s){ !s.nil? } do
          datetime_from_int
        end
      end

      # Events use 'title' directly, not 'headline' like news
      rename_keys teaser: :excerpt

      slugify_data

      accept_keys Entities::Event.attribute_names
      constructor_inject Entities::Event
    end
  end
end

