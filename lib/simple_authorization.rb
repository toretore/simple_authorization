require 'simple_authorization/controller_methods'
require 'simple_authorization/model_methods'

ActionController::Base.send(:include, SimpleAuthorization::ControllerMethods::Application)
I18n.load_path.unshift(File.join(File.dirname(__FILE__), '..', 'config', 'locales', 'simple_authorization.yml'))
