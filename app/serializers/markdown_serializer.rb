module Serializers
  class MarkdownSerializer < TaoPress::Serializer
    include Import['markdown_writer']

    def self.content_to_markdown
      ->(content) {
        str = ""
        headline = content.headline
        if headline
          str << ["#" * headline.level, headline.text, "\n\n"].join(" ")
        end
        case content
        when Entities::Content::Text
          str << content.text
          str
        when Entities::Content::Gallery
          str << "# Galerie\n\n" unless headline
          str << content.images.inject([]) do |result, image|
            alt_text = image.meta.alt || image.meta.title || 'Gallery Image'
            result << "![#{alt_text}](#{image.path})"
            result
          end.join("\n\n")
          str
        when Entities::Content::Image
          str
        when Entities::Content::Download
          str << "# Download\n\n" unless headline
          str << "[#{content.file.name}](#{content.file.path})"
        when Entities::Content::YouTube
          str << "# YouTube\n\n" unless headline
          str << "ID: #{content.youtube_id}"
        else
          raise Application::Error.new("unknown content element type for #{content}", :invalid_data)
        end
      }
    end

    serialize :title do |obj|
      obj.title.gsub(/:/,":")
    end
    serialize :content do |obj|
      obj.content.map(&content_to_markdown).join("\n\n")
    end
    serialize :author do |obj|
      obj.author.email
    end
    serialize :date do |obj|
      obj.published_at.strftime('%Y-%m-%d %H:%M:%S %z')
    end
    serialize :author do |obj|
      obj.author.email
    end

    def call(dirname, news)
      news.map(&serialize_and_write(dirname))

      dirname
    rescue Errno::ENOENT
      raise Application::Error.new("Output directory does not exist", :invalid_data)
    end

    private

    def serialize_and_write(dirname)
      -> (n) {
        path = File.join(
          dirname,
          "%s-%s.md" % [n.published_at.strftime("%Y-%m-%d"), n.slug]
        )
        markdown_writer.(path:) do |f|
          f.puts markdown_template % markdown_variables(n)
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

    def markdown_variables(news_item)
      self.class.serializers.reduce({}) do |acc, (key, p)|
        acc.merge(key => p.(news_item))
      end
    end
  end
end
