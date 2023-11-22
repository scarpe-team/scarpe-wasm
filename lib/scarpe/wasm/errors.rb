# frozen_string_literal: true

module Scarpe
  class UnknownShoesEventAPIError < Scarpe::Error; end

  class UnknownShapeCommandError < Scarpe::Error; end

  class UnknownBuiltinCommandError < Scarpe::Error; end

  class UnknownEventTypeError < Scarpe::Error; end

  class MissingAppError < Scarpe::Error; end

  class MissingDocRootError < Scarpe::Error; end

  class MissingWranglerError < Scarpe::Error; end

  class IllegalSubscribeEventError < Scarpe::Error; end

  class IllegalDispatchEventError < Scarpe::Error; end

  class DuplicateCallbackError < Scarpe::Error; end

  class JSBindingError < Scarpe::Error; end

  class JSInitError < Scarpe::Error; end

  class PeriodicHandlerSetupError < Scarpe::Error; end

  class WebWranglerNotRunningError < Scarpe::Error; end

  class NonexistentEvalResultError < Scarpe::Error; end

  class MissingAttributeError < Scarpe::Error; end

  class InvalidClassError < Scarpe::Error; end

  class MissingClassError < Scarpe::Error; end

  class BadDisplayClassType < Scarpe::Error; end
end
