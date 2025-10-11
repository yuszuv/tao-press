require "dry/struct"

module Entities
  class File < Dry::Struct
    attribute :path, Types::String
  end
end
