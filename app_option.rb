# まくまく Ruby ノート コマンドライン引数によるオプションに対応する (optparse)
# http://maku77.github.io/ruby/io/optparse.html
# コマンドラインツールのショートオプションをどの用途で使うべきか
# https://qiita.com/key-amb/items/9e53cf363407a379d17b
class AppOption
  require 'optparse'

  # インスタンス化と同時にコマンドライン引数をパース
  def initialize
    @options = {}
    OptionParser.new do |o|
      o.on('-n', '--dryrun', 'ファイルへの保存を行わない') { |v| @options[:dryrun] = v }
      o.on('-s', '--short', 'レコードを1件だけ収集') { |v| @options[:short] = v }
      # o.on('-n VALUE', '--num VALUE', 'レコードのプレイ履歴収集数') { |v| @options[:num] = v }
      o.on('-h', '--help', 'show this help') {|v| puts o; exit }
      o.parse!(ARGV)
    end
  end

  # オプションが指定されたかどうか
  def has?(name)
    @options.include?(name)
  end

  # オプションごとのパラメータを取得
  def get(name)
    @options[name]
  end

  # オプションパース後に残った部分を取得
  def get_extras
    ARGV
  end
end