# Cafetro! 開発メモ

ダウンロード者向けREADMEは、作者提供の文面を整理した `Cafetro/README.txt` です。同じ文面をGitHub Releaseにも使用します。この開発メモは配布ZIPには含めません。

## 構成

- `Cafetro/`: 配布するMOD本体。ジョーカー16種、Chun-Chunシール、ソロお題5種＋最終お題＋動作確認用お題2種、水嶋咲のトランプスキン。
- `art/source/`: ジョーカーとアイコンの原稿。`art/COLOR_PALETTE.json` に画像の順序・座標を記載。
- `tools/`: アトラス生成とリリースZIP作成。
- `tests/`: Lua 5.1の能力検証、画像・配布パッケージ検証。`fixtures/practice.lua` は旧お試しライブの検証データ。
- `docs/`: 開発資料、画像一覧、旧版の変更・検証履歴。
- `dist/`: 生成したZIPとSHA-256。Gitには含めず、GitHub Releaseの添付ファイルにする。

表示名は **Cafetro!**。既存セーブとの互換性のため、内部MOD ID `CafeParade`、prefix `cp`、ジョーカー・お題・スキンの内部キー、アトラスキーは維持します。`Cafetro.json` のファイル名とインストールフォルダ名は変更しています。

MOD一覧の説明は `Cafetro/localization/{ja,en-us}.lua` の `descriptions.Mod.CafeParade` に行ごとに定義します。メタデータの `description` はフォールバックです。カードのカテゴリは `badges.lua` で5人＋サタンだけをCafeParade、他のカードをCafetro!とし、MOD自体の表示名は変更しません。

通常の追加・調整は開発版に蓄積し、バージョン番号を据え置きます。未公開の変更は [CHANGELOG.md](CHANGELOG.md) にまとめ、ユーザーのリリース指示を受けた時点で番号を確定して公開します。

## 開発コマンド

リポジトリのルートから実行します。画像・ZIPは更新が必要なときにだけ再生成します。

```sh
python -m pip install -r tests/requirements.txt
python tests/run.py
python tools/build_atlas.py --filter nearest
python tools/build_release.py
```

テストは一時ディレクトリを使い、追跡済みの画像を書き換えません。ZIP作成はPython標準ライブラリだけで動きます。ゲーム実行にPythonは不要です。

- 能力の仕様: [CARD_SPEC.md](CARD_SPEC.md)
- 原稿・アトラス: [ASSET_GUIDE.md](ASSET_GUIDE.md)
- お題の構成: [CHALLENGE_GUIDE.md](CHALLENGE_GUIDE.md)
- 検証範囲と実ゲームでの確認項目: [TEST_PLAN.md](TEST_PLAN.md)
- 配布手順: [RELEASING.md](RELEASING.md)

本体・Lovely・Steamoddedを起動する環境はなく、描画・セーブの実エンジン動作・お題の難易度は未確認です。自動検証の通過と実ゲームの受け入れ確認を区別してください。

## ネガティブ枚数の連携

Cafetro! の読み込み後、`SMODS.Mods.CafeParade.cafeparade` から取得できます。

```lua
local cafetro = SMODS.Mods.CafeParade
local api = cafetro and cafetro.cafeparade
if api then
    local counts_as_negative = api.is_negative_equivalent(card)
    local owned_count = api.count_negative_equivalent()
end
```

- `is_negative_equivalent(card)` は1枚を判定します。エディションのネガティブフラグ、原作のキーとタイプ、Chun-Chunシールを扱います。
- `count_negative_equivalent()` はジョーカー・消耗品・所持トランプから重複を除いて数えます。既存の `negative_count()` は同じ関数を指します。
- 独自キーでネガティブを定義するMODは `api.register_negative_edition('e_example_negative')` で連携できます。
- `card.edition.negative` を直接読む他MODのジョーカーには、このAPIへ切り替える個別互換パッチが必要です。標準の `copy_card` を通らない複製処理も、複製先で一時シールを除去する個別対応が必要です。
- JokerDisplayが先に読み込まれていれば、想楽はそのラウンドの残り付与枚数、雨彦は現在倍率を表示します。標準のJokerDisplayはCafetro!より先に読み込まれます。
