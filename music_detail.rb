class MusicDetail
  def collect_detail(driver, all)
    driver.navigate.to "https://ongeki-net.com/ongeki-mobile/record/musicGenre/search/?genre=99&diff=3"
    page_numbers = driver.find_elements(:name, 'idx').map{|e| e.property('value').to_i}
    driver.navigate.to "https://ongeki-net.com/ongeki-mobile/record/musicGenre/search/?genre=99&diff=10"
    page_numbers += driver.find_elements(:name, 'idx').map{|e| e.property('value').to_i}
    page_numbers = page_numbers[0, 1] unless all

    @record = []
    for music_id in page_numbers do
      music_detail_url="https://ongeki-net.com/ongeki-mobile/record/musicDetail/?idx=#{music_id}"
      puts "#{music_detail_url}を解析中…"
      driver.navigate.to music_detail_url

      title = driver.find_element(:xpath, '//div[contains(@class, "m_5 f_14 break")]').text

      score_level = driver.find_elements(:xpath, '//div[contains(@class, "score_level_base f_l")]')
        .map{|e| 
        e.find_element(:tag_name, 'div').text.gsub("+",".5")
      }

      difficulty = driver
                     .find_elements(:xpath, '//img[contains(@class, "m_5 f_l")]')
                     .map{|e| e.property('src')}
                     .select{|s| s.start_with?("https://ongeki-net.com/ongeki-mobile/img/diff_")}
                     .map{|e| e[/.*diff_([a-z]+)\.png/,1]}

      play_datetime_count = driver.find_elements(:xpath, '//table[contains(@class, "t_r f_11 l_h_10")]')
        .map{|e| 
        e.find_elements(:tag_name, 'td').map(&:text)
      }

      last_play_datetime = play_datetime_count.map{|a| a[1]}
      play_count = play_datetime_count.map{|a| a[3].to_i}

      #play_count = driver.find_elements(:xpath, '//td[contains(@class, "t_r")]').map(&:text).map{|s| s[/([0-9,.]+)/, 1].gsub(/,/, '_').to_i}.to_a

      score_values = driver.find_elements(:xpath, '//table[contains(@class, "score_table")]')
        .map{|e| 
        e.find_elements(:tag_name, 'td').map(&:text).map{|s| s[/([0-9,.]+)/, 1].gsub(/,/, '_')}
      }

      over_damage_high_score = score_values.map{|a| a[0].to_f}
      battle_high_score = score_values.map{|a| a[1].to_i}
      technical_high_score = score_values.map{|a| a[2].to_i}

      # <img src="https://ongeki-net.com/ongeki-mobile/img/music_icon_br_unbelievable.png?ver=1.01">
      # <img src="https://ongeki-net.com/ongeki-mobile/img/music_icon_tr_sssplus.png?ver=1.01">
      # <img src="https://ongeki-net.com/ongeki-mobile/img/music_icon_fb.png">
      # <img src="https://ongeki-net.com/ongeki-mobile/img/music_icon_ab.png?ver=1.01">
      # 空はicon_back.png
      badge_image_names = driver
                     .find_elements(:xpath, '//div[contains(@class, "music_score_icon_area t_r f_0")]')
                     .map {|e|
                       e.find_elements(:tag_name, 'img')
                        .map{|ie| ie.property('src')[/.*icon_([a-z_]+)\.png/,1].gsub("back","")}
                     }

      battle_rank = badge_image_names.map{|a| a[0].gsub("br_","")}
      technical_rank = badge_image_names.map{|a| a[1].gsub("tr_","")}
      full_bell = badge_image_names.map{|a| a[2].gsub("fb","full_bell")}
      full_combo = badge_image_names.map{|a| a[3].gsub("fc","full_combo").gsub("ab","all_break")}

      card_levels = driver.find_elements(:xpath, '//span[contains(@class, "main_color")]').map{|s| s.text.scan(/[0-9]+/).first.to_i}.each_slice(3)

      card_level1 = card_levels.map{|a| a[0]}
      card_level2 = card_levels.map{|a| a[1]}
      card_level3 = card_levels.map{|a| a[2]}

      card_image_names = driver
                     .find_elements(:xpath, '//div[contains(@class, "card_block f_l col3 f_0")]')
                     .map {|e|
                      e.find_element(:tag_name, 'img')
                       .property('src')[/.*card\/(.+)\.png/,1]
                     }.each_slice(3)

      card_image_name1 = card_image_names.map{|a| a[0]}
      card_image_name2 = card_image_names.map{|a| a[1]}
      card_image_name3 = card_image_names.map{|a| a[2]}

      difficulty.length.times do |n|
        @record << "#{last_play_datetime[n]},#{music_id},#{title},#{difficulty[n]},#{score_level[n]},#{play_count[n]},#{battle_rank[n]},#{over_damage_high_score[n]},#{battle_high_score[n]},#{technical_rank[n]},#{technical_high_score[n]},#{full_bell[n]},#{full_combo[n]},#{card_level1[n]},#{card_image_name1[n]},#{card_level2[n]},#{card_image_name2[n]},#{card_level3[n]},#{card_image_name3[n]}"
      end
    end

    p @record
  end

  def save(now = Time.now)
    filename = "music_detail_#{now.strftime('%Y%m%d_%H%M%S')}.csv"

    File.open(filename, 'w') do |f|
      f.puts "最終プレイ日時,楽曲ID,曲名,難易度,譜面レベル,プレイ回数,バトル評価,オーバーダメージ,バトルスコア,テクニカル評価,テクニカルスコア,フルベル,フルコン,カード1のレベル,カード1のファイル名,カード2のレベル,カード2のファイル名,カード3のレベル,カード3のファイル名"
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

music_detail = MusicDetail.new
music_detail.collect_detail(driver, !option.has?(:short))
music_detail.save unless option.has?(:dryrun)
