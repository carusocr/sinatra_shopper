=begin
Shopper home page should list...what?

1. list of available stores, checkboxes by each.
2. text box to accept search term. Each entry will populate the searchterm array.
3. 'Shop!' button.

=end

require 'sinatra'
require 'haml'
require 'capybara'

Capybara.current_driver = :selenium #keeping it visual for now
pathmark = 'http://pathmark.apsupermarket.com/view-circular?storenum=532#ad'
pathmark_prices = Hash.new

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
      $meaty_targets.each do |m|
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
        end
      end

    end

 
  end

  class APS #SuperFresh and Pathmark
    include Capybara::DSL
    def get_results(store,pricelist)
      storename = store[/http:\/\/(.+?)\./,1]
      visit(store)
      page.driver.browser.switch_to.frame(0)
      $meaty_targets.each do |m|
        #find(:xpath,"//input[@id='txtSearch']").set(m)
        page.fill_in('txtSearch', :with => m)
        puts "Looking for #{m}..."
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
    end
  end

end

def scan_price(storename, item_name, target_item, item_price)
 if item_name =~ /#{target_item} ?/ #added \W to eliminate 'roasted' etc.
   puts "#{storename}: #{item_name} for #{item_price}."
   $prices << ["#{storename}","#{item_name}","#{item_price}"]
 end
end

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
  pathmark = params['pathmark']
  superfresh = params['superfresh']
  puts pathmark, superfresh
  #shop_fer_stuff
  redirect '/'
end

post '/' do
  $search_items << params[:item]
  puts $search_items.inspect
  redirect '/'
end

=begin
shop = Shopper::AcmeFroGro.new
shop.get_results(acme,acme_prices)
shop.get_results(frogro,frogro_prices)
shop = Shopper::APS.new
shop.get_results(pathmark,pathmark_prices)
shop.get_results(superfresh,superfresh_prices)
=end
