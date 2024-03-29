require 'rubygems'
require 'bundler'

Bundler.setup

require 'test/unit'

require 'active_support'
require 'active_record'
require 'action_controller'
require 'logger'

require 'strict-forgery-protection'

ActiveRecord::Base.logger = Logger.new('debug.log')
ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
  :database => File.expand_path('../test.sqlite3', __FILE__),
  :timeout => 5000

ActiveRecord::Schema.define do
  create_table :posts, :force => true do |t|
    t.string :message

    t.timestamps
  end
end

class Post < ActiveRecord::Base
end

