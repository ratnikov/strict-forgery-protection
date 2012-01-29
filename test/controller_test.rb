require 'test_helper'

require 'action_dispatch'

class ControllerTest < ActionController::TestCase
  class Controller < ActionController::Base
    def read
      render :json => post
    end

    def update
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

    Post.create! :message => 'hello'
  end

  def test_reads
    get :read, :id => Post.first
  end

  def test_verified_updates
    get :update, :id => Post.first, :authenticity_token => @csrf_token
    post :update, :id => Post.first, :authenticity_token => @csrf_token
  end

  def test_unverified_updates
    assert_raises(ForgeryProtection::AttemptError) { get :update, :id => Post.first, :authenticity_token => 'bad token' }
    assert_raises(ForgeryProtection::AttemptError) { post :update, :id => Post.first, :authenticity_token => 'bad token' }
  end
end
