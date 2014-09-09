require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'pry'
require 'rubygems'
require 'json'
require 'HTTParty'
require_relative './db/connection.rb'
require_relative './lib/author.rb'
require_relative './lib/initmissive.rb'
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
  all_missives = []
  author = Author.find_by(id: params["id"])
  initmissives = InitMissive.where(author_id: params["id"])
  editmissives = EditMissive.where(editor: params["id"])

  erb(:"/authors/show", locals: {author: author, initmissives: initmissives, editmissives: editmissives})
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

get "/missives/new" do
  erb(:"/missives/new", locals: {authors: Author.all()})
end

get "/missives" do
  missives = InitMissive.all() + EditMissive.all()

  author = Author.all()

  erb(:"/missives/index", locals: {missives: missives})
end

post "/missives" do
  if params.include?("initmissive_id")
    initmissive_id = params["initmissive_id"]
    title = params["title"]
    content = params["content"]
    editor = params["editor_id"]

    edit_missive = {initmissive_id: initmissive_id, title: title, content: content, editor: editor}

    EditMissive.create(edit_missive)
  else
    title = params["title"]
    content = params["content"]
    author_id = params["author_id"]

    new_missive = {title: title, author_id: author_id, content: content}

    InitMissive.create(new_missive)
  end
  missives = InitMissive.all()

  erb(:"/missives/index", locals: {missives: missives})
end

get "/missives/show/:id" do
  missive = InitMissive.find_by(id: params["id"]) || missive = EditMissive.find_by(id: params["id"])
  erb(:"/missives/show", locals: { missive: missive})
end

get "/missives/edit/:id" do
  missive = InitMissive.find_by(id: params["id"]) || missive = EditMissive.find_by(id: params["id"])
  authors = Author.all()

  erb(:"/missives/edit", locals: {missive: missive, authors: authors})
end

delete "/missives/:id" do
  missive = InitMissive.find_by({id: params["id"]}) || missive = EditMissive.find_by({id: params["id"]})
  missive.destroy
  redirect "/missives"
end

get "/missives/versions/:id" do
  missive_id = params["id"].split("&")[0]
  init_or_edit_id = params["id"].split("&")[1].to_i.to_s # get rid of leading spaces for second param

  all_missives = []
  if EditMissive.find_by(id: init_or_edit_id) == nil
    # that means its an initMissive...
    all_missives << InitMissive.find_by(id: missive_id)
    all_missives.concat(EditMissive.where(initmissive_id: init_or_edit_id).to_a)
  else
    all_missives.concat(EditMissive.where(initmissive_id: init_or_edit_id).to_a)
  end

  erb(:"/missives/versions", locals: {all_missives: all_missives})
end

post "/missives/subscribe/:id" do
  id = params["id"]
  initedit = params["initedit"]
  name = params["name"]
  title = params["title"]
  email = params["email"]

  params = {
    from: "The Eternia Wiki <postmaster@sandbox8e6d73b42a1944319bf616f4f09f722d.mailgun.org>",
    to: email,
    subject: "Greetings from Eternia",
    text: "Congratulations you've just subscribed to updates for: #{title}"
}

Subscriber.create({name: name, subscribed_post: id, initedit: initedit, email: email})

url = "https://api.mailgun.net/v2/sandbox8e6d73b42a1944319bf616f4f09f722d.mailgun.org/messages"
auth = {:username=>"api", :password=>"key-7f1e23792ed85971de5368c4a92a0e42"}

HTTParty.post(url, {body: params, basic_auth: auth})

  if initedit == "InitMissive"
    if EditMissive.where(initmissive_id: id)
      subscriber = Subscriber.find_by(subscribed_post: id)
      params = {
        from: "The Eternia Wiki <postmaster@sandbox8e6d73b42a1944319bf616f4f09f722d.mailgun.org>",
        to: subscriber["email"],
        subject: "Greetings from Eternia",
        text: "Update to Missive: #{title}"
    }
    url = "https://api.mailgun.net/v2/sandbox8e6d73b42a1944319bf616f4f09f722d.mailgun.org/messages"
    auth = {:username=>"api", :password=>"key-7f1e23792ed85971de5368c4a92a0e42"}

    HTTParty.post(url, {body: params, basic_auth: auth})
    end
  else
    if EditMissive.where(:initmissive_id == id)
      subscriber = Subscriber.find_by(subscribed_post: id)
      params = {
        from: "The Eternia Wiki <postmaster@sandbox8e6d73b42a1944319bf616f4f09f722d.mailgun.org>",
        to: subscriber["email"],
        subject: "Greetings from Eternia",
        text: "Update to Missive: #{title}"
      }
      url = "https://api.mailgun.net/v2/sandbox8e6d73b42a1944319bf616f4f09f722d.mailgun.org/messages"
      auth = {:username=>"api", :password=>"key-7f1e23792ed85971de5368c4a92a0e42"}

      HTTParty.post(url, {body: params, basic_auth: auth})
    end
  end


 # subscribed_missive = InitMissive.find_by(id: id) || subscribed_missive = EditMissive.find_by(id: id)

  erb(:"/missives/subscribed")
end
