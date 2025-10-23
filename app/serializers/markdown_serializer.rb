module Serializers
  class MarkdownSerializer < TaoPress::Serializer
    include Import['markdown_writer']

    serialize :title do |obj|
      obj.title.gsub(/:/,":")
    end
    serialize :content do |obj|
      res = obj.content.reduce("", &content_reducer)

      if res.length == 0
        res = Transformations[:text_markup].(
          Entities::Content::Text.new(
            text: obj.excerpt,
            type: "text",
            headline: nil,
            image: nil,
            images: []),
        )
      end

      if obj.file
        content_reducer.(res, obj.file)
      else
        res
      end
    end
    serialize :author do |obj|
      obj.author.email
    end
    serialize :date do |obj|
      obj.published_at.strftime('%Y-%m-%d %H:%M:%S %z')
    end

    def call(dirname, news)
      news.map(&serialize_and_write(dirname))

      dirname
    rescue Errno::ENOENT
      raise Application::Error.new("Output directory does not exist", :invalid_data)
    end

    def serialize
      -> (ent) { self.class.serializers.reduce({}) do |row, (key, p)|
        row.merge(key => p.(ent))
      end}
    end

    def self.content_reducer
      -> (res, content) {
        content_result = case content
        in Entities::Content::Text
          Transformations[:text_markup].(content)
        in Entities::Content::Gallery
          Transformations[:gallery_markup].(content)
        in Entities::Content::Download
          Transformations[:download_markup].(content)
        in Entities::Content::YouTube
          Transformations[:youtube_markup].(content)
        in Entities::Content::Image
          Transformations[:image_markup].(content)
        in Entities::Content::File
          Transformations[:file_markup].(content)
        end

        if res.length > 0 && content_result.length > 0
          res + "\n\n" + content_result
        else
          res + content_result
        end
      }
    end

    private

    def serialize_and_write(dirname)
      -> (n) {
        path = File.join(
          dirname,
          "%s-%s.md" % [n.published_at.strftime("%Y-%m-%d"), n.slug]
        )
        markdown_writer.(path:) do |f|
          f.puts markdown_template % serialize.(n)
        end
      }
    end

    def markdown_template 
      <<~MD
        ---
        layout: post
        title:  '%{title}'
        date:   %{date}
        author: %{author}
        ---
        %{content}
      MD
    end
  end
end
