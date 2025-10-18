module Entities
  module Content
    class Base < TaoPress::Entity
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

      attribute :type, Types::Content
      attribute :headline, Headline.optional

      attribute :image, Base::Image.optional
    end
  end
end
