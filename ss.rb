=begin
Shopper home page should list...what?

1. list of available stores, checkboxes by each.
2. text box to accept search term. Each entry will populate the searchterm array.
3. 'Shop!' button.

=end

require 'sinatra'
require 'haml'
require 'capybara'

search_items=[]

get '/' do
  haml :home
end

post '/' do
  search_items << params[:item]
  puts search_items.inspect
  @si = search_items
  puts @si.inspect
  redirect '/'
end
