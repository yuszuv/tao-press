module Serializers
  class WordpressSerializer
    def call(post)
      post.to_h.values_at(*CSVWriter::HEADERS)
    end

    def to_proc
      method(:call).to_proc
    end
  end
end
