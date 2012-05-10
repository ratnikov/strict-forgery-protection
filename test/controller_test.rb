require 'test_helper'

require 'action_dispatch'

class ControllerTest < ActionController::TestCase
  class Controller < ActionController::Base
    protect_from_forgery :except => [ :unprotected_read, :unprotected_write ]
    permit_unverified_state_changes :only => [ :db_permitted_read, :db_permitted_write ]

    def read
      render :json => post
    end

    def write
      post.update_attribute :message, params[:message]

      render :json => post
    end

    %w(unprotected db_permitted).each do |prefix|
      define_method("#{prefix}_read") { read }
      define_method("#{prefix}_write") { write }
    end

    private

    def post
      Post.find params[:id]
    end
  end

  tests Controller

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new

    @routes.draw do
      match ':controller/:action(/:id)'
    end

    @controller.extend @routes.url_helpers

    session[:_csrf_token] = @csrf_token = 'secret-csrf-token'

    Post.delete_all

    Post.create! :message => 'hello'
  end

  def test_reads
    %w(read unprotected_read db_permitted_read).each do |read_action|
      get read_action, :id => Post.last
    end
  end

  def test_verified_get_write
    assert_nothing_raised { get :write, :id => Post.last, :authenticity_token => @csrf_token, :message => 'bye' }

    assert_equal 'bye', Post.last.message
  end

  def test_verified_post_write
    assert_nothing_raised { post :write, :id => Post.last, :authenticity_token => @csrf_token, :message => 'bye' }

    assert_equal 'bye', Post.last.message
  end

  def test_unverified_get_write
    assert_raises(ForgeryProtection::AttemptError) { get :write, :id => Post.last, :authenticity_token => 'bad token', :message => 'bye' }
  end

  def test_unverified_post_write
    assert_raises(ForgeryProtection::AttemptError) { post :write, :id => Post.last, :authenticity_token => 'bad token', :message => 'bye' }
  end

  def test_unprotected_writes
    # Unfortunately tripping up developers for just POSTs to bad token with protection disabled is not enough:
    # They are very likely to make the requests via the form, which Rails will include a valid CSRF token for.
    #
    # This would cause this csrf vulnerability to be exposed only when a real attacker attempts to compromise
    # production. Since our checks are done after the action executed, the error would be raised too late. Hence
    # we try to trip up developers when they disable forgery protection and make state changing calls, even if
    # a valid csrf token is specified.
    assert_raises(ForgeryProtection::AttemptError) do
      get :unprotected_write, :id => Post.last, :authenticity_token => @csrf_token, :message => 'bye'
    end

    assert_raises(ForgeryProtection::AttemptError) do
      post :unprotected_write, :id => Post.last, :authenticity_token => @csrf_token, :message => 'good bye'
    end
  end

  def test_db_permitted_verification_write
    before = Post.last.updated_at
    assert_nothing_raised { get :db_permitted_write, :id => Post.last }

    assert_not_equal before, Post.last.updated_at, "Should update the record"
  end

  def test_global_forgery_disabled
    @controller.allow_forgery_protection = false

    assert_nothing_raised do
      get :write, :id => Post.last, :message => 'get bye'
      post :write, :id => Post.last, :message => 'post bye'
    end
  end
end
