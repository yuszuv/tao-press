require "dry/operation"

module TaoPress
  class Operation < Dry::Operation
    include Dry::Monads[:try]
  end
end

