# Café Parade × Balatro — CafeParade v0.3.2

5人のアイドル・サタン・ケーキセットの7枚を追加する、Lovely + Steamodded 用の非公式ファンMODです。アップロードされたジョーカー画像を使用しています。ゲーム本体を書き換える独自パッチはありません。

**実ゲーム起動は未検証です。** このリポジトリに Balatro 本体・Lovely・Steamodded の実行環境はありません。Lua 5.1 の構文とモックによる能力ロジック、画像生成は検証済みですが、実際のスコア処理・表示・セーブ復帰を保証するものではありません。詳細は `TEST_PLAN.md`。

## v0.3.2 の変更

- 咲のMakeup補足と東雲の成長補足を削除。ほかの補足も2〜3行にまとめ、神谷・東雲・サタン・ケーキセットの本文を短くしました。日英とも対応しています。
- 東雲の成長をハンド終了後へ移し、カードの動き・効果音・「成長！X1.05 / Upgraded! X1.05」の表示と同じイベントでX倍率を増やします。成長分は次のハンドから適用されます。
- 成長演出待ちで保存されても、再開時に獲得済みの成長を1回だけ反映します。+8 Mult・成長量0.05、コピー／再発動による二重成長の防止は維持しています。

## v0.3.1 の変更

- ケーキセットの補足ツールチップ「ワンペア限定 / Pair only」を削除し、説明を本文だけに整理しました。

## v0.3.0 の変更

- コモンジョーカー **ケーキセット / Cake Set**（購入価格$4）を追加。画像は `Cake_set_joker.png`、名前・説明・補足は日英対応です。
- **役名がワンペアのときだけ**、そのハンドの得点中にクラブ・ゴード・ウィンドウ・ヘッドのスートによるカード無効化を解除します。ツーペア・フルハウスなど、ペアを含む上位役では発動しません。
- ボス全体は無効化せず、ほかの制限や別原因のカード無効化は残します。ワイルドや手札のスチールにも適用し、得点後に通常の制限へ戻します。咲との左右の順序には依存しません。
- ケーキセットはCafé Paradeメンバー数に含まず、Blueprint/Brainstormのコピー対象外です。複数所持でも解除範囲は増えません。
- 画像を既存6枚の後ろ（`x=6,y=0`）へ追加し、1xを497×95、2xを994×190へ拡張しました。既存カードの座標は維持しています。お試しライブの初期所持は従来の6枚です。

## v0.2.5 の変更

- アスランを `Asselin_joker.png`、神谷幸広を `Kamiya_joker.png` に差し替え、1x／2xアトラスを再生成しました。
- サタンは `Satan_base.png` をベース、`satan_top.png` を独立した前景として使用します。Steamodded標準の `soul_atlas` / `soul_pos` を指定し、レジェンダリーと同じ影・拡縮・揺れで前景を描画します。
- 前景は71×95の透過キャンバスと配置を保ち、ベースの上に重ねます。1枚のPNGへ焼き込んでいません。能力・レアリティ・価格の変更はありません。

## v0.2.4 の変更

- `Art:Potetan` の背景を、落ち着いた黄色寄りのオレンジ **#D6AA60** に変更しました。文字は濃い茶色 **#3C2C18** とし、影を外して読みやすくしています。
- 上段の `CafeParade` はユニットカラー **#CC66CC** と白文字です。

## v0.2.3 の変更

- カードの説明欄にある `CafeParade` バッジの背景を、ユニットカラー **#CC66CC** に変更しました。
- その下に、同じ色の独立した枠で **Art:Potetan** を表示します。文字色は白です。
- Steamodded標準のMODバッジ機能を利用しています。「MODバッジを非表示」を有効にすると、名前と作者表示の両方が非表示になります。

## v0.2.2 の変更

- 咲の処理を **対象選択 → Makeup! → ワイルドの見た目に変化 → 得点演出** の順に変更しました。
- ワイルド化を得点前へ移し、新しく変化したカードにもそのハンドから咲のX1.20とアスランの強化カード効果が適用されます。手役は変化前に確定したものを使います。
- `config.lua` の `saki.makeup_delay`（標準0.4秒）で、文字表示から見た目が変わるまでの間を調整できます。ゲーム速度設定も適用されます。
- ブラインドごとに1回、対象なしなら使用枠を維持、Blueprint/Brainstormでは倍率だけをコピーする条件は維持しています。

## v0.2.1 の変更（旧版）

- 咲が得点カードをワイルドへ変えた瞬間に、対象カードへピンク色の **Makeup!** を表示します。
- 変化したカードと咲のジョーカーを動かし、標準のタロット効果音で知らせます。日英とも同じ表示です。
- 能力・数値・変化タイミングは維持。変化がないハンド、同ブラインドの2回目、Blueprint等のコピーでは演出を出しません。
- 標準の演出処理を使うため、Talismanの演出無効設定を尊重します。演出を確認する際は演出無効をオフにしてください。

## v0.2.0 の変更

- 水嶋咲のトランプスキンを統合。標準の「デッキのカスタマイズ」に、各スーツの **水嶋咲** を追加。
- 通常色とハイコントラストの2種類、各1x／2xに対応。2〜Aの13ランク、4スーツすべてが対象です。
- 旧MODのPNGは加工せずそのまま使用。標準の `cards_1`・`cards_2` を上書きしません。ジョーカーの能力・数値も変更していません。
- 元の利用案内・作者表記は `SAKI_CARDS_NOTICE.txt` に収録。

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
5. ゲームを再起動し Mods メニューの CafeParade、コレクションの7枚、日英の説明を確認します。サタンはレジェンダリーとして登録し、通常の The Soul 経路を使用します。ケーキセットはコモンの通常ショップ枠に出現します。

API 参照対象は Steamodded **26.1002.0**（commit `af0fdb1eb2c9e191262c128bc88bbc4da991e12d`）。公式 `src/utils.lua`、`lovely/center.toml`、`lovely/better_calc.toml`、`lovely/card_limit.toml` の context・enhancement・確率・ライフサイクル処理を確認しました。実際にインストールされたゲーム側のバージョンは確認できていません。最新版で挙動が変わる場合はログとバージョンを記録してください。

## 水嶋咲のトランプを選ぶ

1. ゲームを終了し、**旧MOD「SakiCards」（Saki Mizushima Cards 1.0）を無効化するか、フォルダをModsの外へ移動**します。旧版は標準トランプを上書きするため、同時に読み込むと標準の外見に戻せません。
2. 更新版の `CafeParade_Codex_Starter` の中身を、現在のCafeParadeフォルダへ上書きします。GitHubのZIPには資料用の `Saki Mizushima Cards 1.0` もありますが、**Modsへ入れるのは統合版のフォルダ1つだけ**です。
3. 再起動後、設定の **デッキのカスタマイズ（Customize Deck）** を開きます。
4. ハート／クラブ／ダイヤ／スペードで、それぞれ **水嶋咲** を選びます。変えたいスーツだけ選ぶこともできます。
5. Steamodded標準の配色選択で、通常色・ハイコントラストを切り替えられます。標準デザインへ戻したいスーツは、標準の選択肢へ戻してください。

Steamodded標準の `SMODS.DeckSkin` を使用しており、スキンの選択・設定保存はSteamoddedに委ねています。この機能自体にMalverkは不要です。スキンの変更でカードのランク・スーツ・能力は変わりません。

ユーザー環境で水嶋咲の選択肢の追加とテクスチャ変更を確認したとの報告があります。通常色・ハイコントラストの全画像、選択状態の保存・再起動、他の着せ替えMODとの併用は個別確認が必要です。自動検証では登録内容と元画像の保持を確認しています。

## 実装内容

|ジョーカー|能力|
|---|---|
|神谷幸広|3スートの割り当て成立時、ブラインドに1回$3。1/4で空き枠にタロット。コピーごとに独立した使用枠|
|東雲荘一郎|得点ペアで+8 Mult。ハンド終了後の演出時に永続XMult+0.05、次のハンドから適用|
|アスラン|強化済みの得点カード1発動ごとにX1.25。再発動にも適用|
|卯月巻緒|最も左のペアランクの得点カード、左から2枚に1回ずつ再発動|
|水嶋咲|ワイルド得点ごとにX1.20。ブラインドに1回、得点前に左端の未強化の得点対象カードをワイルド化|
|サタン|有効所持中+1枠。X(2 + 0.25×有効な異種メンバー数 + 成長)。ボス撃破で人数×0.15成長|
|ケーキセット|コモン・$4。ワンペアで得点する間だけ、標準4ボスのスートによるカード無効化を解除|

数値・レアリティ・価格は `config.lua` に集約。サタンの価格はレジェンダリーの標準価格$20を採用（仕様書が許容するAPI既定相当）。メンバー5種の重複は数えず、debuff・サタン・ケーキセット・Blueprint/Brainstormは人数に含めません。

神谷は `card:is_suit` の候補を二部マッチングで割り当てます。ワイルド1枚だけで3スートを成立させません。確率は Steamodded のシード付き確率APIを使用し、確率変更ジョーカーにも従います。消耗品生成の予約枠で同時生成の衝突を防ぎます。コピーによる神谷の使用済みフラグはコピーの `sort_id` ごとに管理します。

成長・使用済みフラグは `card.ability.extra` に保存し、標準セーブに委ねます。ハンド・ブラインドの識別子で二重更新を防ぎます。Blueprint/Brainstormはスコア効果と巻緒の再発動をコピーしますが、東雲・サタンの成長、咲の変化、サタンの増枠はコピーしません。咲は `context.before` で対象と使用枠を確保し、標準の `message` → `func` の解決順を使ってMakeup!を先に予約します。能力は得点前に確定させ、`set_ability` の `delay_sprites` で見た目だけを演出後へ遅らせます。シール・エディションは保持します。

サタンの枠は `add_to_deck` / `remove_from_deck`（debuffを含む）で増減します。ロード時には保存済みの領域上限へ再加算せず、取り消し用の個体フラグだけ復元します。物理複製と能力コピーを区別します。枠が所持枚数未満になってもカードを勝手に削除しません。

## 画像の差し替え

このフォルダで以下を実行します。ゲーム実行に Python は不要です。

```sh
python -m pip install Pillow==12.0.0
python tools/build_atlas.py --filter nearest
# 滑らかな縮小を使う場合:
python tools/build_atlas.py --filter lanczos
```

先に `art/source/{kamiya,shinonome,aslan,makio,saki,satan,cake_set}.png` の必要な原稿を差し替えてください。サタンの `satan.png` はベース専用で、前景は `art/source/satan_top.png` です。生成先は `assets/{1x,2x}/cafeparade_jokers.png` と `cafeparade_satan_top.png`。ゲームを再起動すると反映されます。サイズ・座標・色は `ASSET_GUIDE.md` と `COLOR_PALETTE.json` を参照。

## 自動検証

MODフォルダで:

```sh
python -m pip install -r tests/requirements.txt
python tests/run.py
```

このクラウド環境では `/workspace/.venvs/cafeparade/bin/python tests/run.py` が使用できます。テストは Lupa の **Lua 5.1** を使い、実際の MOD ファイルを読みます。画像生成は一時コピーで実行し、追跡済み画像を書き換えません。テストが通ってもゲームエンジンとの統合確認にはなりません。

## ファイル一覧

- `CafeParade.json`: MODメタデータ・対応Steamoddedバージョン
- `main.lua`: アトラス、アイコン、7種の登録
- `cake_set.lua`: スート制限だけを一時的に除外し、得点後に戻す処理
- `config.lua`: 能力数値・価格・レアリティ
- `common.lua`: 有効メンバー数、ペア選択、スート割り当て、使用済み識別
- `deck_skins.lua`: 4スーツ、通常色／ハイコントラストの選択式スキン登録
- `SAKI_CARDS_NOTICE.txt`: 旧トランプMODの利用案内・作者表記
- `jokers/{kamiya,shinonome,aslan,makio,saki,satan,cake_set}.lua`: 各能力
- `localization/{ja,en-us}.lua`: 日英カード名・説明・現在値
- `tests/run.py`, `tests/contracts.lua`, `tests/cake_set.lua`, `tests/deck_skins.lua`, `tests/requirements.txt`: 構文・ロジック・画像・スキン登録検証
- `TEST_PLAN.md`: 結果と実ゲーム手順
- `PRACTICE_GUIDE.md`: お題の開始方法・確認用ハンド
- `challenges/practice.lua`: 効果確認用のお題
- `README.md`: 本書
- `CODEX_PROMPT.md`, `CARD_SPEC.md`, `ASSET_GUIDE.md`, `COLOR_PALETTE.json`: 制作仕様・画像資料
- `tools/build_atlas.py`: 画像再生成ツール
- `assets/{1x,2x}/{cafeparade_jokers,cafeparade_icon}.png`: ジョーカーのベースとMODアイコン
- `assets/{1x,2x}/cafeparade_satan_top.png`: サタンの独立した前景レイヤー
- `assets/{1x,2x}/saki_cards_{lc,hc}.png`: トランプ画像4枚（元画像をそのまま収録）
- `art/source/{kamiya,shinonome,aslan,makio,saki,satan,cake_set,satan_top}.png`: 原稿8枚
- `previews/{kamiya,shinonome,aslan,makio,saki,satan}_71x95.png`, `previews/cafeparade_card_preview.png`: プレビュー7枚

## お題開始時に `rescale` エラーが出る場合

Steamodded 26.1002.0とMalverk 1.1.3aの組み合わせでは、ブラインド画像の初期化に互換性の問題があります。`blind.lua:754: attempt to call method 'rescale' (a nil value)` が出る場合は、[Malverk公式 v1.1.5](https://github.com/Eremel/Malverk/releases/tag/v1.1.5)以降の対応版へ更新してください。

ゲームを終了し、既存のMalverkフォルダをModsの外へ退避してから、新版を1つだけ配置します。旧版と新版を同時にMods内へ置かないでください。再起動後、Mods一覧のMalverkバージョンを確認し、お題を新しく開始します。

Malverk 1.1.3aは `SMODS.Atlas.pre_inject_class` を無効化しており、ブラインド画像の種別情報が未設定になる場合があります。1.1.5には画像種別と寸法情報を設定する修正があります。Steamoddedの実際の画像生成関数とMalverk各版の初期化処理を使った限定的なテストでは、旧版のエラーを再現し、1.1.5の処理で呼び出しが通ることを確認しました。ユーザー環境での起動と全MODの組み合わせは未検証です。CafeParadeの能力コードに例外を握りつぶす処理は追加していません。

## 既知の制約・権利

バニラカードと Steamodded 標準APIを対象にしています。追加手役・特殊ランク・独自スート・独自セーブ処理を持つ他MODとの完全互換は未検証です。長い日本語名・説明の画面収まりも実ゲームで確認が必要です。神谷の確率失敗でもブラインド使用枠を消費し、咲は対象なしなら消費しません。破壊・消滅済みカードは咲の対象から除きます。

非公式ファン制作です。原作・ゲームの商標・設定は各権利者に帰属します。ジョーカーのイラスト作者表記は `Art:Potetan` です。トランプ画像の作者・元の利用案内は `SAKI_CARDS_NOTICE.txt` を参照してください。配布時には各種ガイドラインを確認してください。
