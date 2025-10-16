require "dry-types"

module Types
  include Dry.Types()

  Content = Types::String.enum(
    'text', 'gallery', 'image', 'download', 'file', 'youtube'
  )
  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
end
