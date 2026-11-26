# Cafetro! 画像の管理

## 原稿と生成先

原稿は `art/source/` に集約しています。同じ絵を複数の場所で管理せず、差し替え後にリポジトリのルートから生成します。

```sh
python tools/build_atlas.py --filter nearest
# 滑らかな補間が必要な場合:
python tools/build_atlas.py --filter lanczos
```

- ジョーカー原稿: `art/source/{id}.png`。カードの比率は71:95。現在は71×95のRGBA。
- アイコン原稿: `art/source/icon.png`。アップロードされた `cafetro_icon.png` と同一の68×68画像。1xは34×34へ縮小し、2xは元PNGのバイトを保持。
- ゲーム用画像: `Cafetro/assets/{1x,2x}/`。生成済み画像を配布するので、ゲーム側には原稿やPythonは不要。
- 画像一覧: `docs/images/cafetro_cards.png`。5列で折り返し、サタンの前景を合成した開発用プレビュー。

## 5列のアトラス

カード数に応じて段数を増やします。現在は16枚・5列×4段で、1xが355×380、2xが710×760。1セルは71×95／142×190です。

|ID|x|y|
|---|---:|---:|
|kamiya|0|0|
|shinonome|1|0|
|aslan|2|0|
|makio|3|0|
|saki|4|0|
|satan|0|1|
|cake_set|1|1|
|chocolate_spacial|2|1|
|plain_cakeroll|3|1|
|three_one_five|4|1|
|embossing|0|2|
|sunsun|1|2|
|goldpeople|2|2|
|amehiko|3|2|
|sora|4|2|
|koron|0|3|

画像の順序・列数は `art/COLOR_PALETTE.json`、ゲームでの登録は `Cafetro/main.lua` にあります。追加時は両方をそろえ、テストで全座標と全画素を確認します。

## サタンの2レイヤー

`art/source/satan.png` はベース、`satan_top.png` は透明な前景です。前景もカード全体のキャンバスを維持し、透明な余白を切り詰めません。共通アトラスのベースに、別の `cafeparade_satan_top.png` を標準の `soul_atlas` / `soul_pos` で重ねます。影・浮遊はSteamodded標準処理を使います。

## 水嶋咲のトランプ

`Cafetro/assets/{1x,2x}/saki_cards_{lc,hc}.png` は統合元の画像を無加工で保持しています。1xは923×380、2xは1846×760。13ランク×4スートで、通常色とハイコントラストの選択式です。アトラス生成ツールはこの4枚を書き換えません。

元画像は、重複した旧MODを削除する前にバイト単位で照合しました。以後は `tests/asset_hashes.json` で保持を検証します。作者提供の利用案内は、MOD全体向けに整えた `Cafetro/README.txt` へ統合しました。旧 `SAKI_CARDS_NOTICE.txt` は配布から外します。ジョーカーの表示には `Art:Potetan` を使用します。

## 雨彦の固定前景

アップロードされた `Amehiko_base.png` を `art/source/amehiko.png`、`Amehiko_joker.png` を `art/source/amehiko_front.png` として、原稿のバイトを変更せず管理します。どちらも71×95・RGBAで、全キャンバスを保持します。

ベースは共通アトラスの `x=3,y=2`、前景は別アトラス `cafeparade_amehiko_front.png`（1x:71×95、2x:142×190）です。ベースのネガティブ・negative_shine描画後、シール・ステッカーより前のDrawStep（order=25）で前景を描きます。`soul_pos` は使わず、前景はカードへGluedで結び、dissolveのみ・追加スケール0・追加回転0・オフセットなしで表示します。`custom_draw` で自動二重描画を防ぎます。

開発用画像一覧は原稿のベース＋前景を合成したものです。ゲームのネガティブシェーダーは一覧PNGでは再現していません。

## Chun-Chunシール

シール原稿は `art/source/chun_chun.png`。71×95の透過キャンバス全体を維持し、`cafeparade_chun_chun.png` を1x／2xに生成します。想楽の原稿は `art/source/sora.png` です。

古論クリスの仮画像は `art/source/koron.png`。この原稿を差し替えて `tools/build_atlas.py` を実行すると、同じアトラス座標に新しい画像が入ります。
