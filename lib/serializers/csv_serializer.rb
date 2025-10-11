module Serializers
  class CSVSerializer
    HEADERS = %i[title subheadline excerpt]

    def call(post)
      post.to_h.values_at(*HEADERS)
    end

    def to_proc
      method(:call).to_proc
    end
  end
end
