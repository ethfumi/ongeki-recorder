# ongeki-recorder

オンゲキのプレイ履歴とプレイヤーデータを収集するやつ。
要スタンダードコース以上です。

https://github.com/Oshiumi/chunithm-recoder を参考にしてます。

# 環境準備

Macの場合。Windowsだと違うかもしれないです。

## Rubyインストール

Rubyは新しければ良さそう。今回の場合は2.5.1。
```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source .bash_profile 

rbenv install 2.5.1
rbenv global 2.5.1
gem install bundler

brew tap homebrew/cask
brew cask install chromedriver
```

## gemfile install

chromedriverが必要
```
gem install bundler
brew tap homebrew/cask
brew cask install chromedriver
```

## リポジトリClone & bundle install

適当なフォルダに移動してから
```
git clone https://github.com/ethfumi/ongeki-recorder.git ./ongeki-recorder
cd ongeki-recorder
bundle install --path=vendor/bundle
```

# 実行方法

`.env-template`を複製し、`.env`をongeki-recorder直下に生成。

`ONGEKI_SEGA_ID`の`your_id`と`ONGEKI_PASSWORD`の`your_password`を書き換える

下記コマンドををongeki-recorder直下で実行。
```
bundle exec ruby app.rb
```

およそ2分後、下記ファイルが生成されます。
```
player_data.csv
playlog_YYYYmmdd-HHMMSS.csv
bp_target_music_YYYYmmdd-HHMMSS.csv
rating_target_music_YYYYmmdd-HHMMSS.csv
music_detail_YYYYmmdd-HHMMSS.csv
```

# 実行結果

playlog_YYYYmmdd-HHMMSS.csv

<img width="493" alt="playlog" src="https://user-images.githubusercontent.com/2544432/46259172-d2b49a00-c510-11e8-8886-61e66e442c28.png">

player_data.csv

<img width="493" alt="player_data" src="https://user-images.githubusercontent.com/2544432/46259202-22936100-c511-11e8-9474-2747bde33ba8.png">
