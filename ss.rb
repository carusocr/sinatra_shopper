=begin
Shopper home page should list...what?

1. list of available stores, checkboxes by each.
2. text box to accept search term. Each entry will populate the searchterm array.
3. 'Shop!' button.

=end

require 'sinatra'
require 'haml'
require 'capybara'

get '/' do

  haml :home

end
