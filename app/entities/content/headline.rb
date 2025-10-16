module Entities
  module Content
    class Headline < TaoPress::Entity
      attribute :text, Types::String
      attribute :level, Types::Integer
    end
  end
end
