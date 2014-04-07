require 'spec_helper'
require 'capybara/rspec'
require_relative '../url_shortener'

Capybara.app = UrlShortener

feature 'Total visits' do
  scenario 'Allows user to see total visits for a URL' do
    visit '/'

    fill_in 'url_to_shorten', with: 'http://livingsocial.com'
    click_on 'Shorten'

    expect(page).to have_text :visible, 'Total visits: 0'

    id = id_of_created_url(current_path)

    visit "/#{id}"

    visit "/#{id}?stats=true"

    expect(page).to have_text :visible, 'Total visits: 1'
  end
end
