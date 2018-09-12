# ongeki-recorder

オンゲキのプレイ履歴を収集するやつ。
要スタンダードコース以上です。

https://github.com/Oshiumi/chunithm-recoder を参考にしてます。

# TODO

## 1件当たりのデータ

* 難易度
* MaxCombo
* 判定情報(CriticalBreakなど)
* Damage
* 種別の精度(Tapなどの割合)
* 遊んだ店舗
* デッキ情報
* 対戦相手
* 対戦相手のレベル
* FULLBELL
* FULLCOMBO
* AllBREAK
* 評価(優など)
* 評価(Sなど)
* 店内マッチング情報

## ユーザーの情報

* 収集した時刻
* 称号
* 名前
* 現在のレベル
* 所持マニー
* 累計マニー
* 親密度
* バトルポイント
* レート
* 最大レート
* トータルプレイTRACK数
* ジュエル
* バトルポイント対象曲 難易度・曲名・スコア
* レーティング対象曲 難易度・曲名・スコア

## 出力

* Json
* Google BigQueryに送る

# 環境準備(Macの場合.Windowsは分からないです)

## Rubyインストール

Rubyは新しければ良さそう。今回の場合は2.5.1
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

`.env-template`を複製し、`.env`をpngeki-recorder直下に生成。

`ONGEKI_SEGA_ID`の`your_id`と`ONGEKI_PASSWORD`の`your_password`を書き換える

下記コマンドををpngeki-recorder直下で実行。tmp.csvが作られます。
```
bundle exec ruby app.rb
```

# 実行結果

<img width="493" alt="aaa" src="https://user-images.githubusercontent.com/2544432/45429672-b9bd8380-b6de-11e8-80c1-2b69fb28be06.png">
