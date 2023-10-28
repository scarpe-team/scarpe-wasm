# frozen_string_literal: true

module Scarpe
  class UnknownShoesEventAPIError < Scarpe::Error; end

  class UnknownShapeCommandError < Scarpe::Error; end

  class UnknownBuiltinCommandError < Scarpe::Error; end

  class UnknownEventTypeError < Scarpe::Error; end

  class UnexpectedFiberTransferError < Scarpe::Error; end

  class MultipleDrawablesFoundError < Scarpe::Error; end

  class NoDrawablesFoundError < Scarpe::Error; end

  class InvalidPromiseError < Scarpe::Error; end

  class MissingAppError < Scarpe::Error; end

  class MissingDocRootError < Scarpe::Error; end

  class MissingWranglerError < Scarpe::Error; end

  class IllegalSubscribeEventError < Scarpe::Error; end

  class IllegalDispatchEventError < Scarpe::Error; end

  class MissingBlockError < Scarpe::Error; end

  class DuplicateCallbackError < Scarpe::Error; end

  class JSBindingError < Scarpe::Error; end

  class JSInitError < Scarpe::Error; end

  class PeriodicHandlerSetupError < Scarpe::Error; end

  class WebWranglerNotRunningError < Scarpe::Error; end

  class NonexistentEvalResultError < Scarpe::Error; end

  class JSRedrawError < Scarpe::Error; end

  class SingletonError < Scarpe::Error; end

  class ConnectionError < Scarpe::Error; end

  class DatagramSendError < Scarpe::Error; end

  class InvalidOperationError < Scarpe::Error; end

  class MissingAttributeError < Scarpe::Error; end

  # This error indicates a problem when running ConfirmedEval
  class JSEvalError < Scarpe::Error
    def initialize(data)
      @data = data
      super(data[:msg] || (self.class.name + "!"))
    end
  end

  # An error running the supplied JS code string in confirmed_eval
  class JSRuntimeError < JSEvalError; end

  # The code timed out for some reason
  class JSTimeoutError < JSEvalError; end

  # We got weird or nonsensical results that seem like an error on WebWrangler's part
  class JSInternalError < JSEvalError; end

  # An error occurred which would normally be handled by shutting down the app
  class AppShutdownError < Scarpe::Error; end

  class InvalidClassError < Scarpe::Error; end

  class MissingClassError < Scarpe::Error; end

  class MultipleShoesSpecRunsError < Scarpe::Error; end

  class EmptyPageNotSetError < Scarpe::Error; end

  class BadDisplayClassType < Scarpe::Error; end
end
