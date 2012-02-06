require 'test_helper'

require 'action_dispatch'

class ControllerTest < ActionController::TestCase
  class Controller < ActionController::Base
    skip_forgery_protection :only => :touch

    def read
      render :json => post
    end

    def update
      post.update_attributes! :message => params[:message]

      render :json => post
    end

    def touch
      post.touch

      render :json => post
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
    get :read, :id => Post.last
  end

  def test_verified_get
    assert_nothing_raised { get :update, :id => Post.last, :authenticity_token => @csrf_token, :message => 'bye' }

    assert_equal 'bye', Post.last.message
  end

  def test_verified_post
    assert_nothing_raised { post :update, :id => Post.last, :authenticity_token => @csrf_token, :message => 'bye' }

    assert_equal 'bye', Post.last.message
  end

  def test_unverified_get
    assert_raises(ForgeryProtection::AttemptError) { get :update, :id => Post.last, :authenticity_token => 'bad token', :message => 'bye' }
  end

  def test_unverified_post
    assert_raises(ForgeryProtection::AttemptError) { post :update, :id => Post.last, :authenticity_token => 'bad token', :message => 'bye' }
  end

  def test_skipped_verification
    before = Post.last.updated_at
    assert_nothing_raised { get :touch, :id => Post.last }

    assert_not_equal before, Post.last.updated_at, "Should update the record"
  end
end
