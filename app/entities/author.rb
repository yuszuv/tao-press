module Entities
  class Author < TaoPress::Entity
    attribute :email, Types::String
    attribute :name, Types::String
  end
end
