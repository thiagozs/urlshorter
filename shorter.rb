require "rubygems" if RUBY_VERSION < '1.9'
require "sinatra"
require "active_record"
require "haml"


ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'db/sinatra.sqlite3.db')

class Uri < ActiveRecord::Base
    validates_format_of :original_uri, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
end

before do
  content_type "text/html", :charset => "utf-8"
end

get '/' do
  haml :index
end


get '/info/:hash' do
  @uri = Uri.find_by_uri_hash(params[:hash])
  haml :info
end


get '/:hash' do
  uri = Uri.find_by_uri_hash(params[:hash])
  throw :halt, [404, not_found ] unless uri

  s = Uri.update(uri.id, :count => uri.count.to_i+1)
  s.save

  redirect uri.original_uri
end


post '/create' do

  c_uri = Uri.find_by_original_uri(params[:original_uri])

  if c_uri.nil? && Uri.new({:original_uri=>params[:original_uri]}).valid?
    o =  [('0'..'9'),('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    string  =  (0..4).map{ o[rand(o.length)] }.join
    uri = Uri.create!(:original_uri => params[:original_uri], :uri_hash => string)
    redirect "/info/#{uri.uri_hash}"
  else
    redirect "/info/#{c_uri.uri_hash}"
  end
end


not_found do
  haml :notfound
end





