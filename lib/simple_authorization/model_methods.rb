module SimpleAuthorization
  module ModelMethods


    module Role


    end


    module User

      def has_roles?(*required_roles)
        required_roles.flatten!
        options = required_roles.last.is_a?(Hash) ? required_roles.pop : {}

        return true if required_roles.empty?

        role_identifiers = roles.map(&:identifier)
        required_roles.map!(&:to_s)

        if options[:all]
          required_roles.all?{|r| role_identifiers.include?(r) }
        else
          required_roles.any?{|r| role_identifiers.include?(r) }
        end
      end

      def has_role?(role)
        has_roles?(role)
      end

    end


  end
end
