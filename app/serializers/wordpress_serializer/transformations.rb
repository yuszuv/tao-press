require "reverse_markdown"

module Serializers
  class WordpressSerializer
    module Transformations
      extend Dry::Transformer::Registry

      def self.file_markup(content, base_url)
        template = <<~FILE
          <!-- wp:stackable/button-group -->
          <div class="wp-block-stackable-button-group stk-block-button-group stk-block" >
            <div class="stk-row stk-inner-blocks stk-block-content stk-button-group">
            <!-- wp:stackable/button -->
            <div class="wp-block-stackable-button stk-block-button stk-block" >
              <a class="stk-link stk-button stk--hover-effect-darken" href="%{href}" target="_blank" rel="noreferrer noopener">
              <span class="stk-button__inner-text">%{text}</span>
              </a>
            </div>
            <!-- /wp:stackable/button -->
            </div>
          </div>
          <!-- /wp:stackable/button-group -->
        FILE

        content => { path:, name: text }

        href = URI::Parser.new.escape(
          File.join(
            base_url,
            File.basename(path).gsub(/\s/,'-').to_slug.transliterate(:german).to_s
          )
        )

        template % { href:, text: text || "Download" }
      end

      def self.image_markup(content, base_url)
        content => { file: { name: alt, path: }}

        template = <<~IMAGE
          <!-- wp:image {"scale":"cover","sizeSlug":"large","linkDestination":"none","align":"center"} -->
          <figure class="wp-block-image aligncenter size-large">
            <img src="%{src}" alt="%{alt}" style="object-fit:cover"/>
          </figure>
          <!-- /wp:image -->
        IMAGE

        src = URI::Parser.new.escape(
          File.join(
            base_url,
              File.basename(path).gsub(/\s/,'-').gsub(/-+/, "-").to_slug.transliterate(:german).to_s
          )
        )

        template % { src:, alt: }
      end

      def self.content_image_markup(content, base_url)
        return "" unless content.image

        template = <<~IMAGE
          <!-- wp:image {"scale":"cover","sizeSlug":"large","linkDestination":"none","align":"center"} -->
          <figure class="wp-block-image aligncenter size-large">
            <img src="%{src}" alt="%{alt}" style="object-fit:cover"/>
          %{caption}</figure>
          <!-- /wp:image -->
        IMAGE

        content => { image: { meta: { alt:, caption: }, path: } }

        src = URI::Parser.new.escape(
          File.join(
            base_url,
              File.basename(path).gsub(/\s/,'-').gsub(/-+/, "-").to_slug.transliterate(:german).to_s
          )
        )

        caption &&= "\n<figcaption class=\"wp-element-caption\">#{caption}</figcaption>"

        template % { src:, caption:, alt: }
      end

      def self.gallery_markup(content, base_url)
        <<~FIGURE.chomp
          <!-- wp:gallery {"linkTo":"none","sizeSlug":"medium"} -->
          <figure class="wp-block-gallery has-nested-images columns-default is-cropped">
            %{images}
          </figure>
          <!-- /wp:gallery -->
        FIGURE
        .then do |s|
          s.%(images: content.images.reduce("") do |acc, img|
            src = URI::Parser.new.escape(
              File.join(
                base_url,
                  File.basename(img.path).gsub(/\s/,'-').gsub(/-+/, "-").to_slug.transliterate(:german).to_s
              )
            )

            caption = img.meta.caption && 
              "\n<figcaption class=\"wp-element-caption\">#{img.meta.caption}</figcaption>"
              .then{ _1.force_encoding(Encoding::UTF_8) }

            acc + <<~IMAGE.chomp
              <!-- wp:image {"sizeSlug":"medium","linkDestination":"none","align":"center","className":"size-thumbnail"} -->
              <figure class="wp-block-image aligncenter size-medium">
                <img src="%{src}" alt="" />
              %{caption}</figure>
              <!-- /wp:image -->
            IMAGE
              .%({src:, caption:, alt: img.meta.alt})
          end)
        end
      end

      def self.text_markup(content, base_url)
        md = ReverseMarkdown.convert(content.text)
        doc = Commonmarker.parse(md, options: { parse: { smart: true }, render: { unsafe: true } })

        doc.walk do |node|
          if node.type == :paragraph && node.parent && node.parent.type == :document
            # wrap first level elements
            if node.type == :paragraph
              node.insert_before(
                Commonmarker.parse("<!-- wp:paragraph -->")
              )
              node.insert_after(
                Commonmarker.parse("<!-- /wp:paragraph -->")
              )

            elsif node.type == :heading
              node.insert_before(
                Commonmarker.parse("<!-- wp:heading -->")
              )
              node.insert_after(
                Commonmarker.parse("<!-- /wp:heading -->")
              )
            end

          # wrap elements generally
          elsif node.type == :list
            node.insert_before(
              Commonmarker.parse("<!-- wp:list -->")
            )
            node.insert_after(
              Commonmarker.parse("<!-- /wp:list -->")
            )
          elsif node.type == :item
            node.insert_before(
              Commonmarker.parse("<!-- wp:list-item -->")
            )
            node.insert_after(
              Commonmarker.parse("<!-- /wp:list-item -->")
            )
          elsif node.type == :link
            next if node.url =~ /^mailto|http/

            new_url = File.join(
              base_url,
              File.basename(node.url).gsub(/\s/,'-').to_s
            )
            node.url = new_url
          end
        end

        doc.to_html(options: { render: { unsafe: true } })
      end

      def self.download_markup(content, base_url)
        template = <<~TEMPLATE
          <!-- wp:paragraph -->
          <p>
            <a href="%{link}" target="_blank" rel="noreferrer noopener">%{name}</a>
          </p>
          <!-- /wp:paragraph -->
        TEMPLATE

        link = content.file.path
        link = URI::Parser.new.escape(
          File.join(
            base_url,
            File.basename(link).gsub(/\s/,'-').gsub(/-+/, "-").to_slug.transliterate(:german).to_s
          )
        )
        name = content.file.name

        template % { link:, name: }
      end

      def self.youtube_markup(content)
        "<!-- youtube id: #{content.youtube_id} //-->"
      end
    end
  end
end
