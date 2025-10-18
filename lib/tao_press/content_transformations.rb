module TaoPress
  module ContentTransformations
    module_function

    def content_guard(value, type, fn)
      return value unless value.is_a? Hash

      value[:type] == type.to_s ? fn[value] : value
    end

    def replace_contao_insert_tags(content)
      regexp = /{{file::([a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})(?:\|urlattr|\|attr|\|absolute|)}}/

      image_finder = ->(uuid) {
        content[:images].find{ |i| i[:uuid] == uuid }
      }

      content[:text] = content[:text]
        .gsub(regexp) do
          uuid = Regexp.last_match(1)
          image = image_finder.(uuid)
          path = image[:path]

          path || uuid
        end

      content
    end

    def slugify_data(data)
      slug = data[:alias].length > 0 ?
        data[:alias].to_slug.normalize(transliterate: :german).to_s :
        data[:title].to_slug.normalize(transliterate: :german).to_s
      data.merge(slug:)
    end


    def slugify_path(str)
      filename = File.basename(str)

      File.join(
        File.dirname(str),
        filename.to_slug.transliterate(:german).to_s
      )
    end

    def parse_heading_level(str)
      str.to_s.length > 0 ? str.to_s[/\d{1,}/].to_i : nil
    end
  end
end
