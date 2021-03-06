# Yossy

## サイト概要
キャバクラ専用、リアルタイム型の勤怠、売上管理システム


### サイトテーマ
その日の店舗状況をリアルタイムで記録し、売上やプラマイ、客の入り状況をワンタッチで共有することができる

### テーマを選んだ理由
キャバクラや水商売界隈ではIT化が全く進んでおらず、上層部がexelも使えないという店舗も数多くある。
しかし、営業中は客の入れ替わりが激しく、キャストに対する客数の差（以下プラマイ）、どの客にどのキャストがついているのか、１時間毎の売り上げはいくらか、現金はどれだけあるのか、卓ごとの時間管理、請求金額の計算（客によって計算が異なる）等々リアルタイムに把握し処理しなければならないことが多すぎる。

特に請求金額の計算や、プラマイの管理はクレームの主原因になり得る項目であるため、情報の共有が最重要事項としてあげられる。
とある店舗では現状それらの情報の共有は都度ライン等のSNSを用いて確認を行なっているが、返信までのラグや確認漏れなどにより事故につながる恐れがある、そのため店内業務が人に依存する形となり、休みたくても休めない、責任の押し付け合いにまで発展してしまう。

そのため、サイトを確認すれば店内状況を一目で把握できるツールがあれば、キャバクラ業界が抱える人依存問題を解消し、円滑に営業することができると考えこのアプリケーションを作ろうと考えました。

### ターゲットユーザ
キャバクラ店経営者

### 主な利用シーン
営業時間中の情報共有

## 設計書

### 機能一覧
<https://docs.google.com/spreadsheets/d/1ddT0dgtKlk3_65DZiANy3qWRDVqldl2Y2QbFEpR7P3A/edit?usp=sharing>

## 開発環境
- OS：Linux(CentOS)
- 言語：HTML,CSS,JavaScript,Ruby,SQL
- フレームワーク：Ruby on Rails
- JSライブラリ：jQuery または　react redux
- 仮想環境：Vagrant