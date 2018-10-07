require './ongeki_web_driver'
require './app_option'
require './playlog'
require './player_data'
require './bp_target_music'
require './rating_target_music'

option = AppOption.new

driver = OngekiWebDriver.new.login

# レコードのプレイ履歴収集
playlog = Playlog.new
playlog.collect_detail(driver, !option.has?(:short))
playlog.save unless option.has?(:dryrun)

# プレイヤーデータ収集
player_data = PlayerData.new
player_data.collect(driver)
player_data.save unless option.has?(:dryrun)

# bp対象曲
bp_target_music = BpTargetMusic.new
bp_target_music.collect(driver)
bp_target_music.save unless option.has?(:dryrun)

# rating対象曲
rating_target_music = RatingTargetMusic.new
rating_target_music.collect(driver)
rating_target_music.save unless option.has?(:dryrun)