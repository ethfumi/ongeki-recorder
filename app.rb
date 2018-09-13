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

# プレイヤーデータ取得
# プレイヤーデータの表示
driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/home/playerDataDetail/'

now = Time.now

trophy = driver.find_element(:xpath, '//div[contains(@class, "trophy_block trophy_3 f_11 f_b")]').text
reincarnation = driver.find_element(:xpath, '//div[contains(@class, "reincarnation_block")]').text.to_i
lv = driver.find_element(:xpath, '//div[contains(@class, "lv_block white")]').text.to_i
battle_point = driver.find_element(:xpath, '//div[contains(@class, "battle_point_17")]').text.gsub(/,/, '_').to_i
name = driver.find_element(:xpath, '//div[contains(@class, "name_block f_15")]').text

rating = driver.find_element(:xpath, '//span[contains(@class, "rating_shadow f_20 f_b")]').text.to_f
max_rating = driver.find_element(:xpath, '//span[contains(@class, "f_11")]').text.gsub(/（MAX (.+)）/) {|_|$1}.to_f

# TODO "所持マニー 12,103（累計 652,103）\nトータルプレイTRACK数 1355"
money, total_money, total_track = driver.find_element(:xpath, '//table[contains(@class, "t_l f_13")]').text.scan(/[0-9,]+/).map{|s| s.gsub(/,/, '_').to_i}

# ジュエル
driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/record/'

jewel_wild = driver.find_element(:xpath, '//span[contains(@class, "v_m p_3 f_14 gray")]').text.gsub(/,/, '_').to_i
jewels = driver.find_elements(:xpath, '//span[contains(@class, "v_m p_3 f_14 white")]').map(&:text).map{ |s| s.gsub(/,/, '_').to_i}

# todo:親密度とりあえず柚子だけ
driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/character/characterDetail/?idx=1001'

friendly_image_numbers = driver.find_element(:xpath, '//div[contains(@class, "character_friendly_conainer f_l")]')
                 .find_elements(:tag_name, 'img')
                 .map{|e| e.property('src').scan(/[0-9]+/)}

friendly_yuzu = friendly_image_numbers[4][0].to_i * 100 + friendly_image_numbers[1][0].to_i + friendly_image_numbers[2][0].to_i

player_record="#{now},#{name},#{trophy},#{total_track},,#{total_money},#{reincarnation*100+lv},#{battle_point},#{rating},#{max_rating},,,,,,,#{friendly_yuzu},#{jewel_wild},#{jewels[-1]}"

p player_record

player_data_filename='player_data.csv'

File.open(player_data_filename, 'a') do |f|
    f.puts player_record
end


