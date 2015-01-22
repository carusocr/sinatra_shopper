=begin
Shopper home page should list...what?

1. list of available stores, checkboxes by each.
2. text box to accept search term. Each entry will populate the searchterm array.
3. 'Shop!' button.

=end

require 'sinatra'
require 'haml'
require 'capybara'

$search_items=[]

def shop_fer_stuff
  $search_items.each do |i|
    sleep 3
    puts "shopping for #{i}...\n"
  end
end

get '/' do
  haml :home
end

post '/shop' do
  shop_fer_stuff
  redirect '/'
end

post '/' do
  $search_items << params[:item]
  puts $search_items.inspect
  redirect '/'
end
