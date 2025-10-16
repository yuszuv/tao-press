module Serializers
  class CSVSerializer < TaoPress::Serializer
    serialize :title
    serialize :subheadline
    serialize :excerpt
    serialize :content do |obj|
      obj.content
    end
  end
end
