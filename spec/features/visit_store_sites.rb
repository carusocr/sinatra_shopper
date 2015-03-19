require 'spec_helper'
pathmark_url = 'http://pathmark.apsupermarket.com/view-circular?storenum=532#ad'
feature "user visits Pathmark" do
  visit pathmark_url
  expect(page).to have_content("Search")
end
=begin
require "rails_helper"

feature "user creates person" do

  scenario "with valid data" do
    fname = 'Zug'
    add_person(fname)
    expect(page).to have_content("Person created. #{fname}")
  end

  def add_person(fname)
    visit 'http://localhost:3000/people/new'
    fill_in('person_first_name', with: fname)
    click_button('Create Person')
  end

end
~                                                                                            
~      
=end
