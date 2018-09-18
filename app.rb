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

wait = Selenium::WebDriver::Wait.new(:timeout => 103)
record = []
50.times do |i|
#1.times do |i|
  playlog_detail_url="https://ongeki-net.com/ongeki-mobile/record/playlogDetail/?idx=#{i}"
  puts "#{playlog_detail_url}を解析中…"
  driver.navigate.to playlog_detail_url
  date = driver.find_element(:xpath, '//span[contains(@class, "f_r f_12 h_10")]').text
  # break unless date.match?(/^#{(Time.now-60*60*24).strftime("%Y-%m-%d")}/)
  title = driver.find_element(:xpath, '//div[contains(@class, "m_5 l_h_10 break")]').text
  bs, over_damage, ts = driver.find_elements(:xpath, '//div[contains(@class, "f_20")]').map(&:text).map{ |s| s[/([0-9,.]+)/, 1].gsub(/,/, '_').to_f}.to_a
  battle_score = bs.to_i
  technical_score = ts.to_i
  # https://ongeki-net.com/ongeki-mobile/img/diff_master.png
  difficulty = driver
                 .find_element(:xpath, '//div[contains(@class, "m_10")]')
                 .find_elements(:tag_name, 'img')
                 .map{|e| e.property('src')}
                 .select{|s| s.start_with?("https://ongeki-net.com/ongeki-mobile/img/diff_")}
                 .first[/.*diff_([a-z]+)\.png/,1]

  # battle_rank https://ongeki-net.com/ongeki-mobile/img/score_br_great.png
  # technical_rank https://ongeki-net.com/ongeki-mobile/img/score_tr_aaa.png
  battle_rank, technical_rank = driver
                 .find_elements(:xpath, '//td[contains(@class, "w_65")]')
                 .flat_map{|e| e.find_element(:tag_name, 'img').property('src')[/.*[tr|br]_([a-z]+)\.png/,1]}

  # https://ongeki-net.com/ongeki-mobile/img/score_detail_win.png 勝利時
  # https://ongeki-net.com/ongeki-mobile/img/score_detail_lose.png 敗北時(途中落ち)
  # https://ongeki-net.com/ongeki-mobile/img/score_detail_fb.png フルBELL
  # https://ongeki-net.com/ongeki-mobile/img/score_detail_fb_base.png なにもない時
  # https://ongeki-net.com/ongeki-mobile/img/score_detail_fc_base.png なにもない時
  # full_bellとfull_comboは計算のほうがいいかな…。
  result = driver
                 .find_element(:xpath, '//div[contains(@class, "clearfix p_t_5 t_l f_0")]')
                 .find_elements(:tag_name, 'img')
                 .map{|e| e.property('src')}
                 .first[/.*detail_([a-z]+)\.png/,1]

  max_combo, score_critical_break, score_break, score_hit, score_miss, score_bell, max_bell, score_detial_tap, score_detial_hold, score_detial_flick, score_detial_side_tap, score_detial_side_hold = driver.find_elements(:xpath, '//td[contains(@class, "f_b")]').map(&:text).flat_map{ |s| s.split('/').map{|s2| s2.gsub(/,/, '_').to_i} }
  score_damage = driver.find_element(:xpath, '//tr[contains(@class, "score_damage")]').text.scan(/[0-9]+/).first.to_i

  full_bell = result != "lose" && score_bell == max_bell ? "full_bell" : ""
  note_num = score_critical_break + score_break + score_hit + score_miss
  full_combo = if result == "lose" || note_num != max_combo then
  	    ""
  	 elsif note_num == (score_critical_break + score_break) then
     	"all_break"
     else
     	"full_combo"
     end

  place_name = driver.find_element(:xpath, '//span[contains(@class, "d_b p_10")]').text
  matching1, matching2, matching3 = driver.find_elements(:xpath, '//div[contains(@class, "border_block")]').map(&:text)

  # record << {
  #    'title' => title,
  #    'date' => date,
  #    'difficulty' => difficulty,
  #    'battle_rank' => battle_rank,
  #    'battle_score' => battle_score,
  #    'over_damage' => over_damage,
  #    'technical_rank' => technical_rank,
  #    'technical_score' => technical_score,
  #    'result' => result,
  #    'full_bell' => full_bell,
  #    'full_combo' => full_combo,
  #    'max_combo' => max_combo,
  #    'critical_break' => score_critical_break,
  #    'break' => score_break,
  #    'hit' => score_hit,
  #    'miss' => score_miss,
  #    'bell' => score_bell,
  #    'damage' => score_damage,
  #    'tap' => score_detial_tap,
  #    'hold' => score_detial_hold,
  #    'flick' => score_detial_flick,
  #    'side_tap' => score_detial_side_tap,
  #    'side_hold' => score_detial_side_hold,
  #    'place_name' => place_name,
  #    'matching1' => matching1,
  #    'matching2' => matching2,
  #    'matching3' => matching3,
  # }

  record << "#{title},#{date},#{difficulty},#{battle_rank},#{battle_score},#{over_damage},#{technical_rank},#{technical_score},#{result},#{full_bell},#{full_combo},#{max_combo},#{score_critical_break},#{score_break},#{score_hit},#{score_miss},#{score_bell},#{score_damage},#{score_detial_tap},#{score_detial_hold},#{score_detial_flick},#{score_detial_side_tap},#{score_detial_side_hold},#{place_name},#{matching1},#{matching2},#{matching3}"
end

# 旧形式
# driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/record/playlog/'
# driver.save_screenshot 'tmp.png'

# dates = driver.find_elements(:xpath, '//span[contains(@class, "f_r f_12 h_10")]').map(&:text)
# titles = driver.find_elements(:xpath, '//div[contains(@class, "m_5 l_h_10 break")]').map(&:text) 
# scores = driver.find_elements(:xpath, '//div[contains(@class, "f_20")]').map(&:text).map{ |s| s[/([0-9,.]+)/, 1].gsub(/,/, '_').to_f}.each_slice(3).to_a

# #record = dates.zip(titles, scores).select { |d, _, _| d.match?(/^#{(Time.now-60*60*24).strftime("%Y/%m/%d")}/) }.map do |d, t, (bs, od ,ts)|
# record = dates.zip(titles, scores).map do |d, t, (bs, od ,ts)|
#   #{'played_at' => d, 'title' => t, 'battle_score' => bs, 'over_damage' => od, 'technical_score' => ts}
#   "#{d}, #{t}, #{bs.to_i}, #{od}, #{ts.to_i}"
# end

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


