module Entities
  class Event < TaoPress::Entity
    attribute :id, Types::Integer

    attribute :title, Types::String
    attribute :excerpt, Types::String

    attribute :content, Types::Array.of(Content::Base)

    attribute :start_time, Types::DateTime
    attribute :end_time, Types::DateTime.optional
    attribute :location, Types::String.optional
    attribute :file, Types.Instance(Entities::Content::File).optional

    attribute :published_at, Types::DateTime
    attribute :slug, Types::String

    attribute :author, Types.Instance(Entities::Author)
  end
end

