module Entities
  module Content
    class Gallery < Base
      class Image < TaoPress::Entity
        class Meta < TaoPress::Entity
          attribute :title, Types::String.optional
          attribute :alt, Types::String.optional
          attribute :link, Types::String.optional
          attribute :caption, Types::String.optional
        end

        attribute :path, Types::String
        attribute :meta, Meta
      end

      attribute :images, Types::Array.of(Image)
    end
  end
end
