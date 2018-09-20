require './ongeki_web_driver'
require './app_option'
require './playlog'
require './player_data'

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
