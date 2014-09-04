require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require_relative './lib/connection.rb'
require_relative './lib/author.rb'
require_relative './lib/missive.rb'
require_relative './lib/subscriber.rb'

after do
  ActiveRecord::Base.connection.close
end

get "/" do
  erb(:index)
end

get "/authors" do
  erb(:"/authors/index", locals: { authors: Author.all() })
end

get "/authors/new" do
  erb(:"/authors/new")
end
