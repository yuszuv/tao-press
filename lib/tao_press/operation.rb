require "dry/operation"

module TaoPress
  class Operation < Dry::Operation
    def self.method_added(method_name)
      super
      prepend ExceptionHandling if method_name == :call
    end

    include Import[
      'error_handler'
    ]

    module ExceptionHandling
      include Dry::Monads[:try, :result]

      def call(...)
        case x = super
        in Failure(error)
          Failure[error.key, error]
        else
          x
        end
      rescue => e
        if error_handler
          error_handler.(:operation_failed, e)
        else
          raise e
        end
      end
    end

  end
end
