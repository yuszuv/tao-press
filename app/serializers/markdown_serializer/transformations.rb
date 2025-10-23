module Serializers
  class MarkdownSerializer
    module Transformations
      extend Dry::Transformer::Registry

      def self.text_markup(content)
        str = ""
        headline = content.headline
        if headline
          str << ["#" * headline.level, headline.text, "\n\n"].join(" ")
        end

        str << ReverseMarkdown.convert(content.text)

        str
      end

      def self.gallery_markup(content)
        str = ""
        headline = content.headline
        str << "# Galerie\n\n" unless headline

        str << content.images.inject([]) do |result, image|
          alt_text = image.meta.alt || image.meta.title || 'Gallery Image'
          result << "![#{alt_text}](#{image.path})"
          result
        end.join("\n\n")
        str
      end

      def self.image_markup(content)
        content => { file: { name: alt, path: }}

        "[%s](%s)" % [alt, path]
      end

      def self.download_markup(content)
        str = ""
        headline = content.headline
        str << "# Download\n\n" unless headline
        str << "[#{content.file.name}](#{content.file.path})"
        str
      end

      def self.youtube_markup(content)
        content => { youtube_id: }

        "<!-- youtube id: #{youtube_id} //-->"
      end

      def self.file_markup(content)
        content => { path:, name: text }

        text ||= "Download"

        str = ""
        str << "# %s\n\n" % text
        str << "[%s](%s)" % [text, path]
        str
      end
    end
  end
end
