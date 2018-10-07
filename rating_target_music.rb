class RatingTargetMusic
  def collect(driver, now = Time.now)
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/home/ratingTargetMusic/'

    # <div class="music_label p_5 break">初音ミクの激唱</div>
    titles = driver.find_elements(:xpath, '//div[contains(@class, "music_label p_5 break")]').map(&:text)

    # <img src="https://ongeki-net.com/ongeki-mobile/img/diff_lunatic.png">
    difficulties = driver
                     .find_elements(:tag_name, 'img')
                     .map{|e| e.property('src')}
                     .select{|s| s.start_with?("https://ongeki-net.com/ongeki-mobile/img/diff_")}
                     .map{|s| s[/.*diff_([a-z]+)\.png/,1]}

    # <div class="f_14 l_h_12">12,272,217</div>
    scores = driver.find_elements(:xpath, '//div[contains(@class, "f_14 l_h_12")]').map(&:text).map{ |s| s[/([0-9,.]+)/, 1].gsub(/,/, '_').to_i}

    kinds = Array.new(30, "best") + Array.new(10, "recent")

    @record = titles.zip(difficulties, scores, kinds).map do |t, d, s, k|
      "#{now},#{t},#{d},#{s},#{k}"
    end
    p @record
  end

  def save(now = Time.now)
    filename = "rating_target_music_#{now.strftime('%Y%m%d_%H%M%S')}.csv"

    File.open(filename, 'w') do |f|
      @record.each do |r|
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

rating_target_music = RatingTargetMusic.new
rating_target_music.collect(driver)
rating_target_music.save unless option.has?(:dryrun)
