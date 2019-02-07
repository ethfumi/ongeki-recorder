class BpTargetMusic
  def collect(driver, now = Time.now)
    driver.navigate.to 'https://ongeki-net.com/ongeki-mobile/home/bpTargetMusic/'

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

    @record = titles.zip(difficulties, scores).map do |t, d, s|
      "#{now},#{t},#{d},#{s}"
    end
    p @record
  end

  def save(now = Time.now)
    directory = 'ongeki-plus-log'
    FileUtils.mkdir_p(directory) unless FileTest.exist?(directory)
    filename = "bp_target_music_#{now.strftime('%Y%m%d-%H%M%S')}.csv"
    filepath = "#{directory}/#{filename}"

    File.open(filepath, 'w') do |f|
      @record.each do |r|
        f.puts r
      end
    end

    p "#{filepath}に保存しました。"
  end
end

return unless $0 == __FILE__

require './ongeki_web_driver'
require './app_option'

option = AppOption.new
driver = OngekiWebDriver.new.login

bp_target_music = BpTargetMusic.new
bp_target_music.collect(driver)
bp_target_music.save unless option.has?(:dryrun)
