# 仮カード画像の利用・差し替えガイド

## このZIPに含まれているもの
- `assets/1x/cafeparade_jokers.png`: 568×95ピクセル、**71×95を横に8枚並べた**ゲーム用アトラス。
- `assets/2x/cafeparade_jokers.png`: 1136×190ピクセル、**142×190を横に8枚並べた**2倍解像度アトラス。
- `assets/1x/cafeparade_satan_top.png` / `assets/2x/cafeparade_satan_top.png`: 71×95 / 142×190のサタン前景。透過部分も含めたカード全体のキャンバス。
- `assets/1x/cafeparade_icon.png` / `assets/2x/cafeparade_icon.png`: 34×34 / 68×68 の仮MODアイコン。
- `art/source/*.png`: カードの原稿8枚とサタンの前景1枚。現在はいずれも71×95ピクセル。**あとから描く絵をここへ同じファイル名で上書き**してください。縦横比71:95を推奨。高解像度でも構いません。
- `previews/cafeparade_card_preview.png` / `previews/*_71x95.png`: スターター時点の参考画像。画像差し替え時のビルド対象には含まず、現在のゲーム用画像とは異なります。
- `tools/build_atlas.py`: 原稿PNG9枚から、ジョーカーのベースとサタンの前景を別々に再生成するツール。

## アトラス座標（0始まり）
| x | 内部ID | 表示名 | 色 |
|---|---|---|---|
| 0 | kamiya | 神谷幸広 | #D88B83 |
| 1 | shinonome | 東雲荘一郎 | #008E74 |
| 2 | aslan | アスラン＝ベルゼビュートⅡ世 | #6967AB |
| 3 | makio | 卯月巻緒 | #EEC362 |
| 4 | saki | 水嶋咲 | #EB6EA5 |
| 5 | satan | サタン | #777B85 |
| 6 | cake_set | ケーキセット | #D6AA60 |
| 7 | chocolate_spacial | Chocolate Spacial | #B88AA8 |

すべて `y=0` です。画像の中の名前は英字略称で、**ゲーム内の日本語名はローカライズが担当**します。

## サタンの2レイヤー構成

- `Satan_base.png` → `art/source/satan.png` → 共通アトラスの `x=5, y=0`。カード枠と背景だけです。
- `satan_top.png` → `art/source/satan_top.png` → `cafeparade_satan_top.png` の `x=0, y=0`。前景のサタンだけです。
- 前景は透過余白を切り詰めず、元の71×95キャンバス上の位置を保ちます。ベースと同じ縦横比・同じキャンバスで描き直してください。
- `jokers/satan.lua` の `soul_atlas='satan_top'` / `soul_pos={x=0,y=0}` により、標準レジェンダリーの浮遊スプライトとして描画されます。重ねる順序・影・揺れはSteamodded標準処理に任せます。

## 現在のアトラス登録
```lua
SMODS.Atlas {
    key = 'jokers',
    path = 'cafeparade_jokers.png',
    px = 71,
    py = 95
}
SMODS.Atlas {key = 'satan_top', path = 'cafeparade_satan_top.png', px = 71, py = 95}
-- ベースは atlas='jokers', pos={x=0..7,y=0}。
-- サタンだけ soul_atlas='satan_top', soul_pos={x=0,y=0} を追加。
-- atlas / soul_atlas にはSteamoddedがcpプレフィックスを自動付与します。
```

## 描き直した画像を使う
1. 例: 神谷の完成絵を `art/source/kamiya.png` として保存（比率71:95、透過PNG推奨）。
2. Python 3 と Pillow が必要。`python -m pip install Pillow`
3. MODのルートで `python tools/build_atlas.py --filter lanczos` を実行。
4. `assets/1x/` と `assets/2x/` のアトラスが自動更新される。ゲームを再起動して確認。
5. ドット絵を鮮明に保ちたいときは `--filter nearest` を使う。

**注意:** ゲームは個別の `art/source/*.png` ではなく、生成済みの `assets/{1x,2x}/cafeparade_jokers.png` と `cafeparade_satan_top.png` を読みます。イラストを差し替えただけでは反映されず、アトラス再生成が必要です。Codexに「画像を変更したのでアトラスを再生成して」と依頼しても大丈夫です。

## アートの特徴
ゲーム用ジョーカー画像は、アップロードされたイラストへ差し替え済みです。元のPNGと透過を保持し、1x／2xへnearestで変換しています。作者表記は `Art:Potetan`。サタンはベースと前景を分けて使用します。

## 統合版の水嶋咲トランプスキン

- `assets/1x/saki_cards_lc.png`・`saki_cards_hc.png`: 923×380。
- `assets/2x/saki_cards_lc.png`・`saki_cards_hc.png`: 1846×760。
- 横は2、3、4、5、6、7、8、9、10、J、Q、K、Aの13列、縦はハート・クラブ・ダイヤ・スペードの4行です。1セル71×95（2xは142×190）。
- 元の `Saki Mizushima Cards 1.0/assets/{1x,2x}/MizushimaSakiCards_{lc,hc}.png` を名前だけ変更してコピーしています。画像データ・透過は無加工です。
- 通常色とハイコントラストは別ファイルを使用。絵札だけでなく2〜Aすべてに適用します。
- ジョーカー用の `tools/build_atlas.py` はこれらのトランプ画像を書き換えません。今後差し替える場合は、対応する解像度・配色のトランプ画像を直接差し替えます。
- 登録は `deck_skins.lua`。元ゲームのアトラスと衝突しない独自キーを使い、既存の着せ替え項目に追加します。
- 旧MODの利用案内と作者表記は `SAKI_CARDS_NOTICE.txt` に収録しています。
