require 'selenium-webdriver'
require 'dotenv'

class OngekiWebDriver
  def login
    Dotenv.load

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for :chrome, options: options

    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/'

    # ログイン
    driver.find_element(:name, 'segaId').send_keys(ENV['ONGEKI_SEGA_ID'])
    driver.find_element(:name, 'password').send_keys(ENV['ONGEKI_PASSWORD'])
    driver.find_element(:xpath, '//button[contains(@class, "btn_login_block")]').click

    # Aime選択 f_0は一番上のやつ
    driver.find_element(:xpath, '//button[contains(@class, "f_0")]').click

    return driver
  end
end

return unless $0 == __FILE__

driver = OngekiWebDriver.new.login
driver.save_screenshot 'tmp.png'
