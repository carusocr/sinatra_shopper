=begin
Shopper home page should list...what?

1. list of available stores, checkboxes by each.
2. text box to accept search term. Each entry will populate the searchterm array.
3. 'Shop!' button.

* FEATURES TO ADD *

- 'Clear Items' button - DONE
- cleaner format 
- 'Load Usual Suspects' button
- creation of table, option to display table from homepage once table is created
  - changed this to display table on home page...need to clean up format. Color code by store and item.
- sortable table by price/item
- store choices need to persist in between addition of target items

* BUGS

- Can't do the same operation twice, e.g. shop for 1 item at Pathmark. First time works,
* FIXED WITH APS BUT STILL PROBLEMATIC WITH FROGRO
  second fails. Connection error is Errno::ECONNREFUSED at /shop.
http://sqa.stackexchange.com/questions/5833/connection-refused-error-when-running-selenium-with-chrome-and-firefox-drivers

https://swdandruby.wordpress.com/2013/05/11/headless-gem-causes-errnoeconnrefused/

Look into manually creating sessions with rand display ids...

- looks like I didn't have to bother with this if I add a page.driver.quit() statement in the class

=end

require 'sinatra'
require 'haml'
require 'capybara'

Capybara.current_driver = :selenium #keeping it visual for now
$pathmark_url = 'http://pathmark.apsupermarket.com/view-circular?storenum=532#ad'
$pathmark_prices = Hash.new
$superfresh_url = 'http://superfresh.apsupermarket.com/weekly-circular?storenum=747&brand=sf'
$superfresh_prices = Hash.new
$acme_url = 'http://acmemarkets.mywebgrocer.com/Circular/Philadelphia-10th-and-Reed/BE0473057/Weekly/2/1'
$acme_prices = Hash.new
$frogro_url = 'http://thefreshgrocer.shoprite.com/Circular/The-Fresh-Grocer-of-Walnut/E7E1123699/Weekly/2'
$frogro_prices = Hash.new


$search_items=[]
$prices=[]

#how can I improve this structure?
module Shopper
  class AcmeFroGro
    include Capybara::DSL
    def get_results(store, pricelist)
    #this one is different....search based
      storename = store[/http:\/\/(.+?)\./,1]
      searchterm = storename == 'acmemarkets' ? 'Search Weekly Ads' : 'Search Weekly Circular'
      visit(store)
      page.driver.browser.manage.window.resize_to(1000,1000)
      $search_items.each do |m|
        page.fill_in(searchterm, :with => m)
        page.click_button('GO')
        lastpage = page.has_link?('Next Page') ? page.first(:xpath,"//a[contains(@title,'Page')]")[:title][/ of (\d+)/,1].to_i : 0
        page.all(:xpath,"//div[contains(@id,'CircularListItem')]").each do |node|
          item_name = node.first('img')[:alt]
          item_price = node.first('p').text
          pricelist["#{item_name}"] = item_price
          scan_price(storename, item_name, m, item_price)
        end
        for i in 2..lastpage
          sleep 1
          page.first(:link,"Next Page").click
          page.all(:xpath,"//div[contains(@id,'CircularListItem')]").each do |node|
            #(continue assembling hash of prices here)
            item_name = node.first('img')[:alt]
            item_price = node.first('p').text
            pricelist["#{item_name}"] = item_price
            scan_price(storename, item_name, m, item_price)
          end
          sleep 1
        end
        page.driver.quit()
      end

    end

 
  end
  class APS #SuperFresh and Pathmark
    include Capybara::DSL
    Capybara.current_driver = :selenium #keeping it visual for now
    def get_results(store,pricelist)
      storename = store[/http:\/\/(.+?)\./,1]
      visit(store)
      page.driver.browser.manage.window.resize_to(1000,1000)
      page.driver.browser.switch_to.frame(0)
      $search_items.each do |m|
        puts "looking for #{m}..."
        page.fill_in('txtSearch', :with => m)
        page.click_button('Search')
        sleep 1 #no sleep sometimes makes next part fail?
        if page.first(:xpath,"//div[contains(text(),'Sorry')]")
          puts "No results found for #{m}."
          next
        end
        if page.first(:xpath,"//a[contains(@onClick,'showAll()')]")
          page.execute_script "showAll()"
        end
        num_rows = page.first(:xpath,"//td[@class='pagenum']").text.match(/OF (\d+)/).captures
        num_rows[0].to_i.times do |meat|
          item_name =  page.find(:xpath, "//p[@id = 'itemName#{meat}']").text
          item_price = page.find(:xpath, "//p[@id = 'itemPrice#{meat}']").text
          pricelist["#{item_name}"] = item_price
          scan_price(storename, item_name, m, item_price)
        end
        sleep 1
      end
      page.driver.quit()
    end
  end

end

def scan_price(storename, item_name, target_item, item_price)
  if item_name =~ /#{target_item}( |$)/i #added \W to eliminate 'roasted' etc.
    puts "Found #{item_name} for #{item_price}"    
    $prices << ["#{storename}","#{item_name}","#{item_price}"]
  end
end

def shop_fer_stuff
  if $pathmark == 1
    shop = Shopper::APS.new
    shop.get_results($pathmark_url,$pathmark_prices)
  end
  if $superfresh == 1
    shop = Shopper::APS.new
    shop.get_results($superfresh_url,$superfresh_prices)
  end
  if $frogro == 1
    shop = Shopper::AcmeFroGro.new
    shop.get_results($frogro_url,$frogro_prices)
  end
end

get '/' do
  haml :home
end

post '/shop' do
  $pathmark = params['pathmark'].to_i
  $superfresh = params['superfresh'].to_i
  $frogro = params['frogro'].to_i
  $prices=[]
  shop_fer_stuff
  redirect '/'
end

post '/' do
  $search_items << params[:item]
  redirect '/'
end

post '/reset' do
  $search_items = []
  $prices = []
  redirect '/'
end
