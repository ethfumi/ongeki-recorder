require 'selenium-webdriver'
require 'dotenv'
require './playlog'
require './player_data'

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

# レコードのプレイ履歴収集
playlog = Playlog.new
playlog.collect_detail(driver)
playlog.save

# プレイヤーデータ収集
player_data = PlayerData.new
player_data.collect(driver)
player_data.save

