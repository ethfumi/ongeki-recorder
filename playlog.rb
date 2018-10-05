class Playlog
  # todo:必要があり次第allに対応する
  def collect(driver, all)
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/record/playlog/'

    dates = driver.find_elements(:xpath, '//span[contains(@class, "f_r f_12 h_10")]').map(&:text)
    titles = driver.find_elements(:xpath, '//div[contains(@class, "m_5 l_h_10 break")]').map(&:text) 
    scores = driver.find_elements(:xpath, '//div[contains(@class, "f_20")]').map(&:text).map{ |s| s[/([0-9,.]+)/, 1].gsub(/,/, '_').to_f}.each_slice(3).to_a

    #record = dates.zip(titles, scores).select { |d, _, _| d.match?(/^#{(Time.now-60*60*24).strftime("%Y/%m/%d")}/) }.map do |d, t, (bs, od ,ts)|
    @record = dates.zip(titles, scores).map do |d, t, (bs, od ,ts)|
      #{'played_at' => d, 'title' => t, 'battle_score' => bs, 'over_damage' => od, 'technical_score' => ts}
      "#{d}, #{t}, #{bs.to_i}, #{od}, #{ts.to_i}"
    end
    p @record
  end

  def collect_detail(driver, all)
    num = all ? 50 : 1
    @record = []
    num.times do |i|
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

      card_level1, card_level2, card_level3 = driver.find_elements(:xpath, '//span[contains(@class, "main_color")]').map{|s| s.text.scan(/[0-9]+/).first.to_i}
      card_power1, card_power2, card_power3 = driver.find_elements(:xpath, '//span[contains(@class, "sub_color")]').map{|s| s.text.to_i}
      card_image_name1, card_image_name2, card_image_name3 = driver
                     .find_elements(:xpath, '//div[contains(@class, "card_block f_l col3")]')
                     .map {|e|
                      e.find_element(:tag_name, 'img')
                       .property('src')[/.*card\/(.+)\.png/,1]
                     }

      event_point = driver.find_elements(:xpath, '//span[contains(@class, "main_color f_b")]').map(&:text).first&.scan(/[0-9]+/)&.first&.to_i

      # record << {
      #    'date' => date,
      #    'title' => title,
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
      #    'event_point' => event_point,
      #    'place_name' => place_name,
      #    'matching1' => matching1,
      #    'matching2' => matching2,
      #    'matching3' => matching3,
      #    'card_level1' => card_level1,
      #    'card_power1' => card_power1,
      #    'card_image_name1' => card_image_name1,
      #    'card_level2' => card_level2,
      #    'card_power2' => card_power2,
      #    'card_image_name2' => card_image_name2,
      #    'card_level3' => card_level3,
      #    'card_power3' => card_power3,
      #    'card_image_name3' => card_image_name3,
      # }

      @record << "#{date},#{title},#{difficulty},#{battle_rank},#{battle_score},#{over_damage},#{technical_rank},#{technical_score},#{result},#{full_bell},#{full_combo},#{max_combo},#{score_critical_break},#{score_break},#{score_hit},#{score_miss},#{score_bell},#{score_damage},#{score_detial_tap},#{score_detial_hold},#{score_detial_flick},#{score_detial_side_tap},#{score_detial_side_hold},#{event_point},#{place_name},#{matching1},#{matching2},#{matching3},#{card_level1},#{card_power1},#{card_image_name1},#{card_level2},#{card_power2},#{card_image_name2},#{card_level3},#{card_power3},#{card_image_name3}"
    end

    p @record
  end

  def save
    filename = "playlog_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"

    File.open(filename, 'w') do |f|
      @record.each do |r|
        # f.puts r.to_json
        f.puts r
      end
    end

    p "#{filename}に保存しました。"
  end
end

return unless $0 == __FILE__

require './ongeki_web_driver'
require './app_option'

option = AppOption.new
driver = OngekiWebDriver.new.login

playlog = Playlog.new
playlog.collect_detail(driver, !option.has?(:short))
playlog.save unless option.has?(:dryrun)
