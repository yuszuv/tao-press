require "dry/struct"

module Entities
  class Author < Dry::Struct
    attribute :email, Types::String
    attribute :name, Types::String
  end
end
