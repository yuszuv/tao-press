module Entities
  module Content
    class File < TaoPress::Entity
      attribute :name, Types::String
      attribute :path, Types::String
      attribute :extension, Types::String
    end
  end
end

