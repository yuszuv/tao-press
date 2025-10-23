module Entities
  class News < TaoPress::Entity
    attribute :id, Types::Integer
    attribute :title, Types::String
    attribute :subheadline, Types::String
    attribute :excerpt, Types::String
    attribute :content, Types::Any
    attribute :published_at, Types::DateTime
    attribute :slug, Types::String

    attribute :author, Types.Instance(Entities::Author)
    attribute :file, Types.Instance(Entities::Content::File).optional
    attribute :tags, Types::Array.of(Types::String).default([].freeze)

    def attachment_url
      file.path
    end
  end
end
