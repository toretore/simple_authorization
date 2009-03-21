require 'test_helper'
require 'mocha'
require 'simple_authorization/controller_methods'
require 'action_controller'
require 'action_controller/test_process'

class ApplicationController < ActionController::Base
  include SimpleAuthorization::ControllerMethods::Application
  attr_accessor :current_user
end

class HorsesController < ApplicationController
  require_roles :equestrian

  def show
    render :text => "show"
  end
end

ActionController::Routing::Routes.load!
ActionController::Routing::Routes.draw do |map|
  map.resources :horses
end


class ClassMethodsTest < Test::Unit::TestCase

  def test_require_roles_should_add_to_required_roles_array
    kontroller = Class.new(ApplicationController)
    assert_equal [], kontroller.required_roles
    kontroller.require_roles :foo, :bar
    assert_equal [[:foo, :bar]], kontroller.required_roles
    kontroller.require_roles :admin, :only => [:edit]
    assert_equal [[:foo, :bar], [:admin, {:only => [:edit]}]], kontroller.required_roles
  end

  def test_controllers_should_inherit_required_roles
    parent = Class.new(ApplicationController)
    parent.required_roles = [[:foo]]
    child = Class.new(parent)
    assert_equal [[:foo]], child.required_roles
    child.require_roles :bar, :except => :baz
    assert_equal [[:foo], [:bar, {:except => :baz}]], child.required_roles
    assert_equal [[:foo]], parent.required_roles
  end

  def test_forget_roles_should_clear_out_the_required_roles_array
    parent = Class.new(ApplicationController)
    parent.required_roles = [[:foo]]
    parent.forget_roles!
    assert_equal [], parent.required_roles
    child = Class.new(parent)
    parent.required_roles = [[:foo]]
    child.forget_roles!
    assert_equal [], child.required_roles
    assert_equal [[:foo]], parent.required_roles
  end

end


class InstanceMethodsTest < Test::Unit::TestCase

  def setup
    @kontroller = Class.new(ApplicationController)
    @controller = @kontroller.new
    @controller.current_user = stub("User")
  end

  def test_authorize_roles_should_not_call_authorization_failed_when_required_roles_empty
    @controller.expects(:authorization_failed).never
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_not_call_authorization_failed_when_if_block_returns_false
    @kontroller.required_roles = [[:foo, {:if => lambda{ false }}]]
    @controller.expects(:authorization_failed).never
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_not_call_authorization_failed_when_unless_block_returns_true
    @kontroller.required_roles = [[:foo, {:unless => lambda{ true }}]]
    @controller.expects(:authorization_failed).never
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_call_authorization_failed_when_if_block_returns_true
    @kontroller.required_roles = [[:foo, {:if => lambda{ true }}]]
    @controller.expects(:has_roles?).returns(false)
    @controller.expects(:authorization_failed)
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_call_authorization_failed_when_unless_block_returns_false
    @kontroller.required_roles = [[:foo, {:unless => lambda{ false }}]]
    @controller.expects(:has_roles?).returns(false)
    @controller.expects(:authorization_failed)
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_not_call_authorization_failed_when_only_array_does_not_include_action_name
    @kontroller.required_roles = [[:foo, {:only => [:foo]}]]
    @controller.expects(:action_name).returns("bar")
    @controller.expects(:authorization_failed).never
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_not_call_authorization_failed_when_except_array_includes_action_name
    @kontroller.required_roles = [[:foo, {:except => [:foo]}]]
    @controller.expects(:action_name).returns("foo")
    @controller.expects(:authorization_failed).never
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_call_authorization_failed_when_only_array_includes_action_name
    @kontroller.required_roles = [[:foo, {:only => [:foo]}]]
    @controller.expects(:action_name).returns("foo")
    @controller.expects(:has_roles?).returns(false)
    @controller.expects(:authorization_failed)
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_call_authorization_failed_when_except_array_does_not_include_action_name
    @kontroller.required_roles = [[:foo, {:except => [:foo]}]]
    @controller.expects(:action_name).returns("bar")
    @controller.expects(:has_roles?).returns(false)
    @controller.expects(:authorization_failed)
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_call_authorization_failed_when_has_roles_returns_false
    @kontroller.required_roles = [[:foo]]
    @controller.expects(:has_roles?).returns(false)
    @controller.expects(:authorization_failed)
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_not_call_authorization_failed_when_has_roles_returns_true
    @kontroller.required_roles = [[:foo]]
    @controller.expects(:has_roles?).returns(true)
    @controller.expects(:authorization_failed).never
    @controller.send(:authorize_roles)
  end

  def test_authorization_actions_should_arrayify_and_stringify_parameters
    assert_equal ["foo"], @controller.send(:authorization_actions, :foo)
    assert_equal ["foo", "bar"], @controller.send(:authorization_actions, [:foo, "bar"])
  end

  def test_authorize_roles_should_call_authorization_failed_when_no_current_user
    @controller.current_user = nil
    @kontroller.required_roles = [[:foo]]
    @controller.expects(:authorization_failed)
    @controller.send(:authorize_roles)
  end

  def test_authorize_roles_should_not_call_authorization_failed_when_no_current_user_and_no_required_roles
    @controller.current_user = nil
    @controller.expects(:authorization_failed).never
    @controller.send(:authorize_roles)
  end

end


class HorsesControllerTest < ActionController::TestCase

  def test_should_allow_access_when_user_has_role
    @controller.current_user = mock(:has_roles? => true)
    get :show
    assert_response :ok
    assert_equal "show", @response.body.strip
  end

  def test_should_deny_access_when_user_does_not_have_role
    @controller.current_user = mock(:has_roles? => false)
    @controller.expects(:login_url).returns("/login/new")
    get :show
    assert_response :redirect
  end

end
