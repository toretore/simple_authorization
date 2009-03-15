module SimpleAuthorization
  module ControllerMethods

    module Application

      def self.included(controller)
        controller.class_inheritable_accessor :required_roles
        controller.required_roles = []
        controller.extend ClassMethods
        controller.before_filter :authorize
      end

    private

      def authorize
        authorize_roles
      end

      def authorize_roles
        self.class.required_roles.each do |roles|
          options = roles.last.is_a?(Hash) ? roles.last : {}

          next if options[:if] && !options[:if].call(self)
          next if options[:unless] && options[:unless].call(self)
          next if options[:only] && !authorization_actions(options[:only]).include?(action_name)
          next if options[:except] && authorization_actions(options[:except]).include?(action_name)

          authorization_failed unless has_roles?(*roles)
        end
      end

      def has_roles?(*roles)
        current_user.has_roles?(*roles)
      end

      def authorization_failed
        flash[:error] = I18n.t('simple_authorization.authorization_failed')
        redirect_to login_url
      end

      def authorization_actions(actions)
        actions = [actions] unless actions.is_a?(Array)
        actions.map(&:to_s)
      end


      module ClassMethods
      
        def require_roles(*roles)
          required_roles << roles
        end

        def require_role(*role)
          require_roles(*role)
        end

        def forget_roles!
          required_roles.clear
        end

      end


    end

  end
end
