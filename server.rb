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

post "/authors" do
  name = params["name"]
  user_name = params["user_name"]
  bio = params["bio"]
  picture = params["picture"]
  phonenum = params["phoneNum"]
  email = params["email"]

  new_author = {name: name, user_name: user_name, bio: bio, picture: picture, phonenum: phonenum, email: email}

  Author.create(new_author)

  erb(:"/authors/index", locals: {authors: Author.all()})
end

get "/authors/show/:id" do
  author = Author.find_by(id: params["id"])

  erb(:"/authors/show", locals: {author: author})
end

get "/authors/show/:id/edit" do
  author = Author.find_by(id: params["id"])
  erb(:"/authors/edit", locals: {author: author})
end

put "/authors" do
  name = params["name"]
  user_name = params["user_name"]
  bio = params["bio"]
  picture = params["picture"]
  phonenum = params["phoneNum"]
  email = params["email"]

  author = Author.find_by({name: params["name"]})

  update_author = {name: name, user_name: user_name, bio: bio, picture: picture, phonenum: phonenum, email: email}

  author.update(update_author)

  erb(:"/authors/index", locals: { authors: Author.all() })
end

delete "/authors/:id" do
  author = Author.find_by({id: params["id"]})
  author.destroy
  redirect "/authors"
end
