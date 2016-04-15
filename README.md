# Sinatra Shopper

Uses Sinatra and Capybara to automate comparison shopping for groceries. Eventual goal would be to make this into a simple app that could be provided to low-income families for use in automatically finding the best grocery shopping options on a week-by-week basis.

## Usage

```ruby
ruby sinshop.rb
```

The script will launch a web application at http://localhost:4567 with a minimalist
Twitter Bootstrap interface that allows you to specify grocery items you want to search for
and a list of stores you can choose to browse. After adding items and selecting stores, 
hitting the 'Shop' button will launch a set of automated browser processes and assemble the prices
into a store-sorted table, which is subsequently loaded onto the main page. 

## To-do list:

1. Add invisible browser option.
2. Sortable table by item/price.
3. Add option to save/load favorites. 
