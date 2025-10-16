module Entities
  module Content
    class Base < TaoPress::Entity
      attribute :type, Types::Content
      attribute :headline, Headline.optional
    end
  end
end
