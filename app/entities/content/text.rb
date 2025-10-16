module Entities
  module Content
    class Text < Base
      attribute :text, Types::String
      attribute :type, Types::String
    end
  end
end
