# frozen_string_literal: true

module Services
  class TagExtractor
    include Import["ruby_llm", "logger"]

    def call(news_entity)
      return [] if news_entity.nil?

      content_text = extract_content_text(news_entity)
      return [] if content_text.strip.empty?

      extract_tags_with_ai(content_text)
    rescue => e
      logger.error("Tag extraction failed for news #{news_entity.id}: #{e.message}")
      []
    end

    private

    def extract_content_text(news_entity)
      text_parts = []

      # Add title and excerpt
      text_parts << news_entity.title if news_entity.title
      text_parts << news_entity.subheadline if news_entity.subheadline
      text_parts << news_entity.excerpt if news_entity.excerpt

      # Extract text from content
      if news_entity.content.is_a?(Array)
        news_entity.content.each do |content_item|
          case content_item
          when Entities::Content::Text
            text_parts << content_item.text if content_item.text
            text_parts << content_item.headline&.text if content_item.headline&.text
          when Entities::Content::Gallery
            text_parts << content_item.headline&.text if content_item.headline&.text
            # Extract metadata from gallery images
            if content_item.images.is_a?(Array)
              content_item.images.each do |image|
                text_parts << image.meta.title if image.meta&.title
                text_parts << image.meta.alt if image.meta&.alt
                text_parts << image.meta.caption if image.meta&.caption
              end
            end
          when Entities::Content::Image
            text_parts << content_item.headline&.text if content_item.headline&.text
            # Extract metadata from image
            if content_item.image&.meta
              text_parts << content_item.image.meta.title if content_item.image.meta.title
              text_parts << content_item.image.meta.alt if content_item.image.meta.alt
              text_parts << content_item.image.meta.caption if content_item.image.meta.caption
            end
          when Entities::Content::Download
            text_parts << content_item.headline&.text if content_item.headline&.text
          when Entities::Content::YouTube
            text_parts << content_item.headline&.text if content_item.headline&.text
          end
        end
      end

      text_parts.compact.join(" ")
    end

    def extract_tags_with_ai(content_text)
      prompt = build_tag_extraction_prompt(content_text)
      
      response = ruby_llm.chat.ask(prompt)
      
      # Parse the response to extract tags
      tags = response.content.strip.split(/[,\n]/)
        .map(&:strip)
        .reject(&:empty?)
        .first(5) # Limit to 5 tags max
      
      tags
    rescue => e
      logger.error("AI tag extraction failed: #{e.message}")
      []
    end

    def build_tag_extraction_prompt(content_text)
      <<~PROMPT
        Analyze the following news article content and extract 3-5 relevant, descriptive tags.
        Tags should be single words or short phrases that best describe the main topics, themes, or subjects.
        Focus on the most important and specific aspects of the content.
        
        Return only the tags, separated by commas, one per line.
        Do not include any other text or explanations.

        The language of the content is German.
        
        Content:
        #{content_text}
      PROMPT
    end
  end
end
