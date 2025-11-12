require "commonmarker"

module Serializers
  class WordpressSerializer < TaoPress::Serializer
    include Import['csv_writer', 'settings']

    serialize :title
    serialize :subheadline
    serialize :excerpt
    serialize :content do |obj, base_url:|
      res = obj.content.reduce("", &content_reducer(base_url:))

      if res.length == 0
        res = Transformations[:text_markup].(Entities::Content::Text.new(text: obj.excerpt, type: "text", headline: nil, image: nil, images: []), base_url)
      end

      if obj.file
        content_reducer(base_url:).(res, obj.file)
      else
        res
      end
    end
    serialize :images do |obj|
      obj.content.select do |c|
        case c
        when Entities::Content::Text
          true
        else
          false
        end
      end.flat_map do |c|
        c[:images].map(&:path)
      end.join("|")
    end
    serialize :published_at
    serialize :author do |obj|
      obj.author.email
    end
    serialize :tags do |obj|
      obj.tags.join(",")
    end
    

    def call(path, news)
      opts = {
        write_headers: true,
        headers: self.class.serializers.keys,
        force_quotes: true
      }

      csv_writer.(path:, **opts) do |f|
        news
          .map(&serialize)
          .each { f << _1 }

        f
      end
    rescue Errno::ENOENT
      raise Application::Error.new("Output path does not exist", :invalid_data)
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
