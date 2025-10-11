require "dry/struct"

module Entities
  class Post < Dry::Struct
    attribute :id, Types::Integer
    # attribute :type, Types::String.enum(
    #   'text', 'gallery', 'image'
    # )
    attribute :title, Types::String
    attribute :subheadline, Types::String
    attribute :excerpt, Types::String
    attribute :content, Types::String
    attribute :published_at, Types::DateTime
    attribute :slug, Types::String

    attribute :author, Types.Instance(Entities::Author)
    # attribute :attachment_url, Types::String.optional
    attribute :file, Types.Instance(Entities::File).optional
    # attribute :image_urls
  end
end
