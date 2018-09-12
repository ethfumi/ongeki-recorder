require 'selenium-webdriver'
require 'dotenv'
# require 'json'

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

# レコードのプレイ履歴
driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/record/playlog/'

# driver.save_screenshot 'tmp.png'

dates = driver.find_elements(:xpath, '//span[contains(@class, "f_r f_12 h_10")]').map(&:text)
titles = driver.find_elements(:xpath, '//div[contains(@class, "m_5 l_h_10 break")]').map(&:text) 
scores = driver.find_elements(:xpath, '//div[contains(@class, "f_20")]').map(&:text).map{ |s| s[/([0-9,.]+)/, 1].gsub(/,/, '_').to_f}.each_slice(3).to_a

record = dates.zip(titles, scores).map do |d, t, (bs, od ,ts)|
  #{'played_at' => d, 'title' => t, 'battle_score' => bs, 'over_damage' => od, 'technical_score' => ts}
  "#{d}, #{t}, #{bs.to_i}, #{od}, #{ts.to_i}"
end

p record

filename = 'tmp.csv'

File.open(filename, 'w') do |f|
  record.each do |r|
    # f.puts r.to_json
    f.puts r
  end
end