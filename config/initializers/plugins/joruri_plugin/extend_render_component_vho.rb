# encoding: utf-8
module RenderComponent
  module Components
    module InstanceMethods

      private
        # Create a new request object based on the current request.
        # NOT IMPLEMENTED FOR RAILS 3 SO FAR: The new request inherits the session from the current request,
        # bypassing any session options set for the component controller's class
        def request_for_component(controller_path, options)
          if options.is_a? Hash
            old_style_params = options.delete(:params)
            options.merge!(old_style_params) unless old_style_params.nil?
            request_params = options.symbolize_keys
            request_env = {}
            request.env.select {|key, value| key == key.upcase || key == 'rack.input'}.each {|item| request_env[item[0]] = item[1]}
            request_env['REQUEST_URI'] = url_for(options)
            request_env["PATH_INFO"] = url_for(options.merge(:only_path => true))
            request_env["action_dispatch.request.symbolized_path_parameters"] = request_params
            request_env["action_dispatch.request.parameters"] = request_params.with_indifferent_access
            request_env["action_dispatch.request.path_parameters"] = Hash[request_params.select{|key, value| [:controller, :action].include?(key)}].with_indifferent_access
            request_env["warden"] = request.env["warden"] if (request.env.has_key?("warden"))
            request_env["rack.jpmobile"] = request.mobile
            request_env["rack.session.options"] = request.session_options
            component_request = ActionDispatch::Request.new(request_env)
            # its an internal request request forgery protection has to be disabled
            # because otherwise forgery detection might raise an error
            component_request.instance_eval do
              def forgery_whitelisted?
                true
              end
            end
            component_request
          else
            request
          end
        end

    end
  end
end

ActionController::Base.send :include, RenderComponent::Components
