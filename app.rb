require './ongeki_web_driver'
require './app_option'
require './playlog'
require './player_data'
require './bp_target_music'
require './rating_target_music'
require './music_detail'

option = AppOption.new
driver = OngekiWebDriver.new.login
now = Time.now

# プレイヤーデータ収集
player_data = PlayerData.new
player_data.collect(driver, now)
player_data.save unless option.has?(:dryrun)

# bp対象曲
bp_target_music = BpTargetMusic.new
bp_target_music.collect(driver, now)
bp_target_music.save(now) unless option.has?(:dryrun)

# rating対象曲
rating_target_music = RatingTargetMusic.new
rating_target_music.collect(driver, now)
rating_target_music.save(now) unless option.has?(:dryrun)

# レコードのプレイ履歴収集
playlog = Playlog.new
playlog.collect_detail(driver, !option.has?(:short))
playlog.save(now) unless option.has?(:dryrun)

# 楽曲詳細
music_detail = MusicDetail.new
music_detail.collect_detail(driver, !option.has?(:short))
music_detail.save unless option.has?(:dryrun)
