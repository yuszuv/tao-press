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

      t.register(:combine_start_datetime, ->(data) {
        start_date = data[:startDate] ? Transformations.datetime_from_int(data[:startDate]) : nil
        start_time = data[:startTime] && data[:startTime] != 0 ? Transformations.datetime_from_int(data[:startTime]) : nil
        
        if start_date && start_time
          DateTime.new(
            start_date.year, start_date.month, start_date.day,
            start_time.hour, start_time.min, start_time.sec
          )
        elsif start_date
          start_date
        else
          nil
        end
      })

      t.register(:combine_end_datetime, ->(data) {
        end_date = data[:endDate] && data[:endDate] != 0 ? Transformations.datetime_from_int(data[:endDate]) : nil
        end_time = data[:endTime] && data[:endTime] != 0 ? Transformations.datetime_from_int(data[:endTime]) : nil
        
        if end_date && end_time
          DateTime.new(
            end_date.year, end_date.month, end_date.day,
            end_time.hour, end_time.min, end_time.sec
          )
        elsif end_date
          end_date
        else
          nil
        end
      })
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
        guard ->{ !_1.nil? } do
          accept_keys Entities::Content::File.attribute_names
          constructor_inject Entities::Content::File
        end
      end

      map_value :teaser, :to_s.to_proc
      
      # Combine startDate and startTime into a single DateTime
      map_hash do
        add_key :start_date, ->(h) { 
          start_date = h[:startDate] ? Transformations.datetime_from_int(h[:startDate]) : nil
          start_time = h[:startTime] && h[:startTime] != 0 ? Transformations.datetime_from_int(h[:startTime]) : nil
          
          if start_date && start_time
            DateTime.new(
              start_date.year, start_date.month, start_date.day,
              start_time.hour, start_time.min, start_time.sec
            )
          elsif start_date
            start_date
          else
            nil
          end
        }
        add_key :end_date, ->(h) { 
          end_date = h[:endDate] && h[:endDate] != 0 ? Transformations.datetime_from_int(h[:endDate]) : nil
          end_time = h[:endTime] && h[:endTime] != 0 ? Transformations.datetime_from_int(h[:endTime]) : nil
          
          if end_date && end_time
            DateTime.new(
              end_date.year, end_date.month, end_date.day,
              end_time.hour, end_time.min, end_time.sec
            )
          elsif end_date
            end_date
          else
            nil
          end
        }
      end

      # Events use 'title' directly, not 'headline' like news
      rename_keys teaser: :excerpt

      slugify_data

      accept_keys Entities::Event.attribute_names
      constructor_inject Entities::Event
    end
  end
end

