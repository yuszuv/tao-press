module Entities
  class Event < TaoPress::Entity
    attribute :id, Types::Integer
    attribute :title, Types::String
    attribute :subheadline, Types::String.optional
    attribute :excerpt, Types::String
    attribute :content, Types::Any
    attribute :start_date, Types::DateTime
    attribute :end_date, Types::DateTime.optional
    attribute :location, Types::String.optional
    attribute :slug, Types::String

    attribute :author, Types.Instance(Entities::Author)
    attribute :file, Types.Instance(Entities::Content::File).optional
  end
end

