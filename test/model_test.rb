require 'test_helper'
require 'active_support'
require 'mocha'
require 'simple_authorization/model_methods'

class User
  include SimpleAuthorization::ModelMethods::User
  attr_accessor :roles
  def initialize(opts={})
    opts.each{|k,v| send("#{k}=", v) }
  end
end

class UserTest < Test::Unit::TestCase

  def setup
    @user = User.new(:roles => [stub(:identifier => "foo"), stub(:identifier => "bar")])
  end

  def test_has_roles_should_return_true_when_no_roles_specified
    assert @user.has_roles?
    assert @user.has_roles?([])
    assert @user.has_roles?([], :all => true)
    assert @user.has_roles?(:all => false)
  end

  def test_has_roles_should_flatten_arguments_array
    assert @user.has_roles?([[[[:foo],[:bar]]]])
    assert @user.has_roles?(:foo, [:bar], {:all => false})
  end

  def test_has_roles_should_take_strings_and_symbols
    assert @user.has_roles?("foo", :bar)
  end

  def test_has_roles_should_return_true_when_at_least_one_role_matches
    assert @user.has_roles?(:foo)
    assert @user.has_roles?(:bar)
  end

  def test_has_roles_should_return_false_when_no_roles_match
    assert !@user.has_roles?(:admin, :manager)
  end

  def test_has_roles_should_not_require_all_roles_by_default
    assert @user.has_roles?(:foo, :bar, :admin)
  end

  def test_has_roles_should_return_false_when_all_roles_required_and_one_or_more_role_not_found
    assert !@user.has_roles?(:foo, :bar, :admin, :all => true)
  end

  def test_has_roles_should_return_true_when_all_roles_required_and_all_roles_found
    assert @user.has_roles?(:foo, :bar, :all => true)
  end

  def test_has_role_should_forward_to_has_roles
    args = [:foo]
    @user.expects(:has_roles?).with(*args)
    @user.has_role?(*args)
  end

end
