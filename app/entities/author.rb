module Entities
  class Author < Entity
    attribute :email, Types::String
    attribute :name, Types::String
  end
end
