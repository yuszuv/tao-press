module Entities
  module Content
    class Text < Base
      class Image < TaoPress::Entity
        attribute :path, Types::String
        attribute :extension, Types::String
        attribute :name, Types::String

        # attribute :uuid, Types::UUID
        attribute :mtime, Types::DateTime
      end
      attribute :text, Types::String
      attribute :type, Types::String

      attribute :images, Types::Array.of(Image)
    end
  end
end
