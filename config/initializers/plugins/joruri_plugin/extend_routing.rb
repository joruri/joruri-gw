# encoding: utf-8
module ActionDispatch
  module Routing
    class RouteSet
      def call(env)
        Core.initialize(env)
        finalize!
        @router.call(env)
      end
      
      class Dispatcher
      protected
        def dispatch(controller, action, env)
          Core.recognize_path(env['PATH_INFO'])
          rs = controller.action(action).call(env)
          Core.terminate
          rs
        end
      end
    end
  end
end