require_relative "wordpress_serializer/transformations"

module Serializers
  class EventCSVSerializer < TaoPress::Serializer
    # TODO: serialize author and venues

    include Import['csv_writer', 'settings']

    Transformations = WordpressSerializer::Transformations

    serialize :title

    serialize :description do |obj, base_url:|
      res = ""
      if obj.file
        content_reducer(base_url:).(res, obj.file)
      else
        res
      end
    end

    serialize :start_date do |obj|
      obj.start_time.strftime('%Y-%m-%d')
    end
    serialize :start_time do |obj|
      obj.start_time.strftime('%H:%M')
    end
    serialize :end_date do |obj|
    obj.end_time&.strftime('%Y-%m-%d') || obj.start_time.strftime('%Y-%m-%d')
    end
    serialize :end_time do |obj|
      obj.end_time&.strftime('%H:%M') || obj.start_time.strftime('%H:%M')
    end
    serialize :location

    def call(path, events)
      opts = {
        write_headers: true,
        headers: self.class.serializers.keys.map(&header_for_serializer_key),
        force_quotes: true
      }

      csv_writer.(path:, **opts) do |f|
        events
          .map(&serialize)
          .each { f << _1 }

        f
      end
    rescue Errno::ENOENT
      raise Application::Error.new("Output path does not exist", :invalid_data)
    end

    def header_for_serializer_key
      lambda do |key|
        dict = {
          title: "EVENT NAME",
          description: "EVENT DESCRIPTION",
          excerpt: "EVENT EXCERPT",
          start_date: "EVENT START DATE",
          start_time: "EVENT START TIME",
          end_date: "EVENT END DATE",
          end_time: "EVENT END TIME",
          # "TIMEZONE",
          # "ALL DAY EVENT",
          # "HIDE FROM EVENT LISTINGS",
          # "STICKY IN MONTH VIEW",
          location: "EVENT VENUE NAME",
          # "EVENT ORGANIZER NAME",
          # "EVENT SHOW MAP LINK",
          # "EVENT SHOW MAP",
          # "EVENT COST",
          # "EVENT CURRENCY SYMBOL",
          # "EVENT CURRENCY POSITION",
          # "EVENT CATEGORY",
          # "EVENT TAGS",
          # "EVENT WEBSITE",
          # "EVENT FEATURED IMAGE",
          # "ALLOW COMMENTS",
          # "ALLOW TRACKBACKS AND PINGBACKS"

        }

        dict[key] || key
      end
    end

    def serialize
      -> (ent) { self.class.serializers.reduce([]) do |row, (_, p)|
        row << p.(ent, base_url: settings.wordpress_uploads_prefix)
      end}
    end

    def self.content_reducer(base_url:)
      -> (res, content) {
        res + case content
        in Entities::Content::Text
          [:text_markup, :content_image_markup].map do |key|
            Transformations[key].(content, base_url)
          end.join
        in Entities::Content::Gallery
          [:gallery_markup, :content_image_markup].map do |key|
            Transformations[key].(content, base_url)
          end.join
        in Entities::Content::Download
          Transformations[:download_markup].(content, base_url)
        in Entities::Content::YouTube
          Transformations[:youtube_markup].(content)
        in Entities::Content::Image
          Transformations[:image_markup].(content, base_url)
        in Entities::Content::File
          Transformations[:file_markup].(content, base_url)
        end
      }
    end
  end
end

