# Café Parade × Balatro — CafeParade v0.1.1

5人のアイドルとサタンの6枚を追加する、Lovely + Steamodded 用の非公式ファンMODです。仮カード画像をそのまま使用しています。ゲーム本体を書き換える独自パッチはありません。

**実ゲーム起動は未検証です。** このリポジトリに Balatro 本体・Lovely・Steamodded の実行環境はありません。Lua 5.1 の構文とモックによる能力ロジック、画像生成は検証済みですが、実際のスコア処理・表示・セーブ復帰を保証するものではありません。詳細は `TEST_PLAN.md`。

## v0.1.1 の変更

- 能力・数値は変更せず、ゲーム内説明を「倍率 +8」「倍率 X1.25」などの純正に沿った表記に整理。
- 細かな判定は補足ツールチップへ分離。神谷・咲の使用状態は「未使用／使用済み」で表示。
- お題 **「Café Parade：お試しライブ」** を追加。6枚を所持し、全8枚が初手にそろうデッキで開始します。
- 試すハンドと確認ポイントは `PRACTICE_GUIDE.md`。お題のゲーム内開始・表示・挙動は未検証です。

## Windows への導入

1. `%AppData%\Balatro\` のセーブデータをバックアップしてください。
2. [Lovely の公式配布](https://github.com/ethangreen-dev/lovely-injector/releases)から Windows 対応版を取得し、公式手順に従って Balatro 実行フォルダへ配置します（Steam → 管理 → ローカルファイルを閲覧）。参照 Steamodded リリースの Lovely 要件は **0.9.0以上**です。
3. [Steamodded の公式配布](https://github.com/Steamodded/smods/releases)から **26.1002.0以上**の対応版を取得し、公式手順に従い `%AppData%\Balatro\Mods\Steamodded\` に配置します。古いバージョンの残骸と二重導入しないでください。
4. このリポジトリの **`CafeParade_Codex_Starter` フォルダの中身**を `%AppData%\Balatro\Mods\CafeParade\` にコピーします。直下が `CafeParade.json`、`main.lua`、`assets/` になる構成です。リポジトリ全体とこのフォルダを別々に二重配置しないでください。
5. ゲームを再起動し Mods メニューの CafeParade、コレクションの6枚、日英の説明を確認します。サタンはレジェンダリーとして登録し、通常の The Soul 経路を使用します。通常ショップ向けの独自出現処理はありません。

API 参照対象は Steamodded **26.1002.0**（commit `af0fdb1eb2c9e191262c128bc88bbc4da991e12d`）。公式 `src/utils.lua`、`lovely/center.toml`、`lovely/better_calc.toml`、`lovely/card_limit.toml` の context・enhancement・確率・ライフサイクル処理を確認しました。実際にインストールされたゲーム側のバージョンは確認できていません。最新版で挙動が変わる場合はログとバージョンを記録してください。

## 実装内容

|ジョーカー|能力|
|---|---|
|神谷幸広|3スートの割り当て成立時、ブラインドに1回$3。1/4で空き枠にタロット。コピーごとに独立した使用枠|
|東雲荘一郎|得点ペアで+8 Mult、1ハンド1回永続XMult+0.05。成長済みXMultは全ハンドで適用|
|アスラン|強化済みの得点カード1発動ごとにX1.25。再発動にも適用|
|卯月巻緒|最も左のペアランクの得点カード、左から2枚に1回ずつ再発動|
|水嶋咲|ワイルド得点ごとにX1.20。ブラインドに1回、得点後に左端の未強化カードをワイルド化|
|サタン|有効所持中+1枠。X(2 + 0.25×有効な異種メンバー数 + 成長)。ボス撃破で人数×0.15成長|

数値・レアリティ・価格は `config.lua` に集約。サタンの価格はレジェンダリーの標準価格$20を採用（仕様書が許容するAPI既定相当）。メンバー5種の重複は数えず、debuffとサタン自身、Blueprint/Brainstormは人数に含めません。

神谷は `card:is_suit` の候補を二部マッチングで割り当てます。ワイルド1枚だけで3スートを成立させません。確率は Steamodded のシード付き確率APIを使用し、確率変更ジョーカーにも従います。消耗品生成の予約枠で同時生成の衝突を防ぎます。コピーによる神谷の使用済みフラグはコピーの `sort_id` ごとに管理します。

成長・使用済みフラグは `card.ability.extra` に保存し、標準セーブに委ねます。ハンド・ブラインドの識別子で二重更新を防ぎます。Blueprint/Brainstormはスコア効果と巻緒の再発動をコピーしますが、東雲・サタンの成長、咲の変化、サタンの増枠はコピーしません。咲の変化は `context.after` 内で得点後に確定し、シール・エディションを保持します。

サタンの枠は `add_to_deck` / `remove_from_deck`（debuffを含む）で増減します。ロード時には保存済みの領域上限へ再加算せず、取り消し用の個体フラグだけ復元します。物理複製と能力コピーを区別します。枠が所持枚数未満になってもカードを勝手に削除しません。

## 画像の差し替え

このフォルダで以下を実行します。ゲーム実行に Python は不要です。

```sh
python -m pip install Pillow==12.0.0
python tools/build_atlas.py --filter nearest
# 滑らかな縮小を使う場合:
python tools/build_atlas.py --filter lanczos
```

先に `art/source/{kamiya,shinonome,aslan,makio,saki,satan}.png` の必要な原稿を差し替えてください。生成先は `assets/1x/cafeparade_jokers.png` と `assets/2x/cafeparade_jokers.png`。ゲームを再起動すると反映されます。サイズ・座標・色は `ASSET_GUIDE.md` と `COLOR_PALETTE.json` を参照。

## 自動検証

MODフォルダで:

```sh
python -m pip install -r tests/requirements.txt
python tests/run.py
```

このクラウド環境では `/workspace/.venvs/cafeparade/bin/python tests/run.py` が使用できます。テストは Lupa の **Lua 5.1** を使い、実際の MOD ファイルを読みます。画像生成は一時コピーで実行し、追跡済み画像を書き換えません。テストが通ってもゲームエンジンとの統合確認にはなりません。

## ファイル一覧

- `CafeParade.json`: MODメタデータ・対応Steamoddedバージョン
- `main.lua`: アトラス、アイコン、6種の登録
- `config.lua`: 能力数値・価格・レアリティ
- `common.lua`: 有効メンバー数、ペア選択、スート割り当て、使用済み識別
- `jokers/{kamiya,shinonome,aslan,makio,saki,satan}.lua`: 各能力
- `localization/{ja,en-us}.lua`: 日英カード名・説明・現在値
- `tests/run.py`, `tests/contracts.lua`, `tests/requirements.txt`: 構文・ロジック・画像検証
- `TEST_PLAN.md`: 結果と実ゲーム手順
- `PRACTICE_GUIDE.md`: お題の開始方法・確認用ハンド
- `challenges/practice.lua`: 効果確認用のお題
- `README.md`: 本書
- `CODEX_PROMPT.md`, `CARD_SPEC.md`, `ASSET_GUIDE.md`, `COLOR_PALETTE.json`: 制作仕様・画像資料
- `tools/build_atlas.py`: 画像再生成ツール
- `assets/{1x,2x}/{cafeparade_jokers,cafeparade_icon}.png`: 仮画像4枚
- `art/source/{kamiya,shinonome,aslan,makio,saki,satan}.png`: 原稿6枚
- `previews/{kamiya,shinonome,aslan,makio,saki,satan}_71x95.png`, `previews/cafeparade_card_preview.png`: プレビュー7枚

## 既知の制約・権利

バニラカードと Steamodded 標準APIを対象にしています。追加手役・特殊ランク・独自スート・独自セーブ処理を持つ他MODとの完全互換は未検証です。長い日本語名・説明の画面収まりも実ゲームで確認が必要です。神谷の確率失敗でもブラインド使用枠を消費し、咲は対象なしなら消費しません。破壊・消滅済みカードは咲の対象から除きます。

非公式ファン制作です。原作・ゲームの商標・設定は各権利者に帰属します。付属画像は元スターターの仮図形です。配布時には各種ガイドラインを確認してください。
