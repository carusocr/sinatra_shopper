# getting http://stackoverflow.com/questions/7263564/unable-to-obtain-stable-firefox-connection-in-60-seconds-127-0-0-17055
require 'capybara'

Capybara.run_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'http://www.google.com'

module MyCapybaraTest
  class Test
    include Capybara::DSL
    def test_google
      visit('/')
    end
  end
end

t = MyCapybaraTest::Test.new
t.test_google
