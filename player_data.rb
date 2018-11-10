class PlayerData
  def collect(driver, now = Time.now)
    # プレイヤーデータ取得
    # プレイヤーデータの表示
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/home/playerDataDetail/'

    trophy = driver.find_element(:xpath, '//div[contains(@class, "trophy_block")]').text
    reincarnation = driver.find_element(:xpath, '//div[contains(@class, "reincarnation_block")]').text.to_i
    lv = driver.find_element(:xpath, '//div[contains(@class, "lv_block white")]').text.to_i
    battle_point = driver.find_element(:xpath, '//div[contains(@class, "battle_point_")]').text.gsub(/,/, '_').to_i
    name = driver.find_element(:xpath, '//div[contains(@class, "name_block f_15")]').text

    rating = driver.find_element(:xpath, '//span[contains(@class, "f_20 f_b")]').text.to_f
    max_rating = driver.find_element(:xpath, '//span[contains(@class, "f_11")]').text.gsub(/（MAX (.+)）/) {|_|$1}.to_f

    # TODO "所持マニー 12,103（累計 652,103）\nトータルプレイTRACK数 1355"
    money, total_money, total_track = driver.find_element(:xpath, '//table[contains(@class, "t_l f_13")]').text.scan(/[0-9,]+/).map{|s| s.gsub(/,/, '_').to_i}

    # ジュエル
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/record/'
    jewels = driver.find_elements(:xpath, '//span[contains(@class, "v_m p_3 f_14 white")]').map(&:text).map{ |s| s.gsub(/,/, '_').to_i}
    jewel_wild = driver.find_element(:xpath, '//span[contains(@class, "v_m p_3 f_14 gray")]').text.gsub(/,/, '_').to_i
    jewels << jewel_wild

    # # todo:親密度とりあえず柚子だけ
    # # 必要なくなったので閉じる
    # driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/character/characterDetail/?idx=1001'

    # friendly_image_numbers = driver.find_element(:xpath, '//div[contains(@class, "character_friendly_conainer f_l")]')
    #                  .find_elements(:tag_name, 'img')
    #                  .map{|e| e.property('src').scan(/[0-9]+/)}

    # friendly_yuzu = friendly_image_numbers[4][0].to_i * 100 + friendly_image_numbers[1][0].to_i + friendly_image_numbers[2][0].to_i

    # トータルハイスコア
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/ranking/totalHiscore/'

    # all basic advanced expert master lunatic の順
    total_battle_scores = []
    6.times do |i|
      driver.find_elements(:xpath, '//button[contains(@class, "f_0")]')[i].click
      total_battle_scores << driver.find_element(:xpath, '//td[contains(@class, "gray_line f_b")]').text.gsub(/,/, '_').to_i
    end

    Selenium::WebDriver::Support::Select.new(driver.find_element(:name => "scoreType")).select_by(:text, 'テクニカルスコア')
    total_technical_scores = []
    6.times do |i|
      driver.find_elements(:xpath, '//button[contains(@class, "f_0")]')[i].click
      total_technical_scores << driver.find_element(:xpath, '//td[contains(@class, "gray_line f_b")]').text.gsub(/,/, '_').to_i
    end

    # 雑にイベント取得 同時にランキングは開催1個まで、という前提条件付き
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/event/'
    event_ids = driver.find_elements(:name, 'idx').map{|e| e.property('value').to_i}
    # 一番上は常設東方なので下から探索する
    for i in event_ids.reverse do
      event_ranking_url="https://ongeki-net.com/ongeki-mobile/event/ranking/?idx=#{i}"
      puts "#{event_ranking_url}を解析中…"
      driver.navigate.to event_ranking_url
      nums = driver.find_elements(:xpath, '//span[contains(@class, "f_20 f_b")]').map{|e| e.text.scan(/[0-9,]+/).first.gsub(/,/, '_').to_i}

      next if nums.empty?

      event_point = nums[0];
      event_rank = nums[1];
      break
    end

    @record="#{now},#{name},#{trophy},#{total_track},#{money},#{total_money},#{reincarnation*100+lv},#{battle_point},#{rating},#{max_rating},#{event_point},#{event_rank},#{total_battle_scores.join(",")},#{total_technical_scores.join(",")},#{jewels.join(",")}"

    p @record
  end

  def save
    filename='player_data.csv'

    File.open(filename, 'a') do |f|
        f.puts @record
    end

    p "#{filename}に追加保存しました。"
  end
end

return unless $0 == __FILE__

require './ongeki_web_driver'
require './app_option'

option = AppOption.new
driver = OngekiWebDriver.new.login

player_data = PlayerData.new
player_data.collect(driver)
player_data.save unless option.has?(:dryrun)
