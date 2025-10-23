# frozen_string_literal: true

module Services
  class TagExtractor
    include Import[
      "ruby_llm",
      "serializers.markdown_serializer"
    ]

    def call(news)
      md = markdown_serializer.serialize.(news)

      extract_tags_with_ai(md)
    end

    private

    def extract_tags_with_ai(content)
      prompt = build_tag_extraction_prompt(content)

      begin
        response = ruby_llm.chat.ask(prompt)
      rescue => e
        raise Application::Error.new(e.message, :llm_chat_failed, error: e)
      end

      # Parse the response to extract tags
      tags = response.content
        .split(/[,\n]/)
        .map(&:strip)
        .first(5) # Limit to 5 tags max

      tags
    end

    def build_tag_extraction_prompt(content)
      content => { title:, content: body}

      template = <<~PROMPT
        Analyze the following news article content and extract 3-5 relevant, descriptive tags.
        Tags should be single words or short phrases that best describe the main topics, themes, or subjects.
        Focus on the most important and specific aspects of the content.

        Return only the tags, separated by commas, one per line.
        Do not include any other text or explanations.

        The language of the content is German.

        Title: %{title}

        Body:
        %{body}
      PROMPT

      template % { title:, body: }
    end
  end
end
