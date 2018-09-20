class PlayerData
  def collect(driver)
    # プレイヤーデータ取得
    # プレイヤーデータの表示
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/home/playerDataDetail/'

    now = Time.now

    trophy = driver.find_element(:xpath, '//div[contains(@class, "trophy_block trophy_3 f_11 f_b")]').text
    reincarnation = driver.find_element(:xpath, '//div[contains(@class, "reincarnation_block")]').text.to_i
    lv = driver.find_element(:xpath, '//div[contains(@class, "lv_block white")]').text.to_i
    battle_point = driver.find_element(:xpath, '//div[contains(@class, "battle_point_")]').text.gsub(/,/, '_').to_i
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

    @record="#{now},#{name},#{trophy},#{total_track},,#{total_money},#{reincarnation*100+lv},#{battle_point},#{rating},#{max_rating},,,,,,,#{friendly_yuzu},#{jewel_wild},#{jewels[-1]}"

    p @record
  end

  def save
    filename='player_data.csv'

    File.open(filename, 'a') do |f|
        f.puts @record
    end
  end
end
