module Entities
  class Author < TaoPress::Entity
    attribute :email, Types::Email
    attribute :name, Types::String
  end
end
