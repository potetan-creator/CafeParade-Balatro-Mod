# Cafetro! v1.2.0

THE IDOLM@STER™ & ©Bandai Namco Entertainment Inc.

MOD Creator / Art: Potetan

---

## 日本語

### このMODについて

**Cafetro!** は、Steam等で販売されている「Balatro」に、
アイドルマスターSideMのアイドルユニット「CafeParade」をモチーフとした
新要素を追加するファンメイドMODです。

### v1.2.0の変更

- 北村想楽とChun-Chunシールを追加。シールの得点時は倍率+5で、雨彦がネガティブ相当として数えます。
- 「北村想楽：Chun-Chun動作確認」で、想楽・Blueprint・雨彦の連携を試せます。

- 葛之葉雨彦（レア・基本価格$8）を追加。必ずネガティブ加工で出現します。
  基礎倍率X1に、所持するネガティブ1枚につきX0.25を加算。
  自身・消耗品・トランプも対象です。キャラクターは元の色のまま、固定の前景に表示します。
- 動作確認用チャレンジ「葛之葉雨彦：ネガティブ動作確認」を追加。
  全8枚が初手にそろい、ネガティブ5枚・雨彦X2.25から変化を確認できます。
- ケーキセット：ペアを含む役にも対応。ラウンド終了時に1/5の確率で食べられます。
- ロールケーキ：得点カードがちょうど2枚のとき、各+50チップへ調整。
  ラウンド終了時に1/10の確率で食べられます。
- 金人間（レア・$8）を追加。
  所持中、道化師パックにコモンジョーカーが出現しなくなります。
- エンボスジョーカー（コモン・$4）を追加。
  得点する強化カード1枚につき倍率+4。再発動時も加算します。
- スンスン（アンコモン・$6）を追加。
  得点する6のカードを2回追加で再発動します。
  [Fan art of PUPPET SUNSUN (Unofficial)]
- ジョーカー画像を5列×3段へ拡張しました。

### v1.1.0の変更

- 神谷幸広：ブラインドごとの発動制限を撤廃。条件を満たすハンドごとに
  $3を獲得し、1/4の確率でタロットを生成します（空きが必要）。
- サタン：初期倍率をX2からX2.5へ上方調整しました。
- 東雲荘一郎・サタン：倍率の増加量を赤枠で表示し、現在の倍率を
  説明の末尾へまとめました。成長量と成長タイミングは従来どおりです。
- 水嶋咲：「最初のカード」を「一番左のカード」へ変更しました。
  未強化かつ得点対象の左端カードだけが変化する条件は同じです。

### 収録内容

- **トランプ着せ替え「水嶋咲」**
  過去に配布したMODを、ゲーム内の「デッキのカスタマイズ」から
  見た目を切り替えられる形で再実装しています。
- **特別なチャレンジ6つ＋動作確認用2つ**
  CafeParadeの5人が活躍する、個性に合わせたお題を収録しています。
- **新ジョーカー15枚**
  - CafeParadeの5人をモチーフとしたジョーカー：5枚
  - レジェンダリージョーカー「サタン」：1枚
  - メンバーを活かすためのサポートジョーカー：3枚
  - アイドルマスターSideM×FiFS展をモチーフとしたジョーカー：1枚
  - エンボスジョーカー・スンスン・金人間：各1枚
  - 葛之葉雨彦・北村想楽：各1枚

### 制作について

今回はChatGPT-6.1Sol Codexをフル活用し、
ジョーカーの効果のベースや実装などを任せています。

ジョーカーに使われているイラストは、作者本人が
CLIP STUDIO PAINTを使って、チマチマ作りました。

### 利用条件

- このMODはファンによって制作された作品です。
  再配布・第三者による改変版の再配布等を禁じます。
- 配信・動画での利用は自由です。
  公序良俗に反しないようお願いいたします。
- 政治的信条・宗教的信条の主張、またはヘイトスピーチを
  目的として利用することはおやめください。

### 導入方法（Windows / Steam版Balatro）

本MODの使用には、**Lovely Injector**と**Steamodded 26.1002.0以降**が必要です。

#### 1. Lovely Injectorを導入する

1. [Lovely Injectorの公式リリース](https://github.com/ethangreen-dev/lovely-injector/releases)からWindows版をダウンロードします。
2. ZIPを解凍し、`winmm.dll`を`Balatro.exe`と同じフォルダーに配置します。

ゲーム本体のフォルダーは、Steamの
「Balatro → 管理 → ローカルファイルを閲覧」から開けます。
Lovelyを更新する場合は、公式の更新手順に従ってください。

#### 2. Steamoddedを導入する

1. [Steamoddedの公式リリース](https://github.com/Steamodded/smods/releases)をダウンロードして解凍します。
2. Steamoddedのフォルダーを、次の場所に配置します。

```text
%AppData%\Balatro\Mods
```

`Mods`フォルダーが存在しない場合は、新規作成してください。

#### 3. Cafetro!を導入する

1. リリースの添付ファイル`Cafetro-v1.2.0.zip`をダウンロードして解凍します。
2. 中の`Cafetro`フォルダーを`%AppData%\Balatro\Mods`に配置します。
   配置後のパスは次のとおりです。

```text
%AppData%\Balatro\Mods\Cafetro
```

3. `Cafetro`の直下に`Cafetro.json`と`main.lua`があることを確認します。
4. Balatroを起動し、タイトル画面の「Mods」に**Cafetro!**が表示されることを確認してください。

### 注意事項

- MODの導入前に、セーブデータのバックアップを推奨します。
- MODフォルダーが二重にならないよう注意してください。
  旧版を導入済みの場合は、古いフォルダーと重複させずに差し替えてください。
- 起動しない場合は、Lovely・Steamoddedの導入状況とバージョンを確認してください。
- 本MODはSteam版Balatroを対象としています。

---

## English

### About This Mod

**Cafetro!** is a fan-made mod for *Balatro*, available on Steam and other platforms.
It adds new content inspired by **Café Parade**, an idol unit from
*THE IDOLM@STER SideM*.

### Changes in v1.2.0

- Added Sora Kitamura and his Chun-Chun Seal. It gives +5 Mult when scored and counts as Negative for Amehiko.
- Use the Sora Kitamura: Chun-Chun Test challenge to try Sora, Blueprint, and Amehiko together.

- Added Amehiko Kuzunoha (Rare, base cost $8), who always appears Negative.
  Base X1 Mult, increased by X0.25 for each owned Negative card, including
  himself, consumables and playing cards. His portrait retains its original
  colors in a fixed foreground layer.
- Added the "Amehiko Kuzunoha: Negative Test" challenge: all eight playing
  cards fit in the first hand; start with five Negative cards and X2.25 Mult.
- Cake Set now works with any hand containing a Pair and has a 1 in 5 chance
  to be eaten at the end of each round.
- Plain cakeroll now gives +50 Chips per card when exactly two cards score,
  with a 1 in 10 chance to be eaten at the end of each round.
- Added Goldpeople (Rare, $8): Common Jokers no longer appear in Buffoon Packs
  while this Joker is held.
- Added Embossing Joker (Common, $4): each played Enhanced card gives
  +4 Mult when scored, including retriggers.
- Added SUNSUN (Uncommon, $6): retrigger each played 6 two additional times.
  [Fan art of PUPPET SUNSUN (Unofficial)]
- Expanded the Joker atlas to five columns and three rows.

### Changes in v1.1.0

- Yukihiro Kamiya: removed the once-per-blind limit. Each qualifying hand
  earns $3 and has a 1 in 4 chance to create a Tarot card (must have room).
- Satan: increased base Mult from X2 to X2.5.
- Soichiro Shinonome and Satan: growth uses red XMult boxes, with current
  Mult shown on the final line. Growth amounts and timing are unchanged.
- Saki Mizushima: clarified "first played card" as "leftmost played card".
  It must still be unenhanced and part of the scoring hand to transform.

### Included Content

- **Playing Card Skin: Saki Mizushima**
  A reimplementation of my previously released mod, now integrated into
  the in-game Customize Deck menu so you can switch between card designs.
- **6 Special Challenges + 2 Test Challenges**
  Challenges designed to let all five members of Café Parade shine.
- **15 New Jokers**
  - 5 Jokers inspired by the five members of Café Parade
  - 1 Legendary Joker featuring Satan
  - 3 support Jokers designed to complement the members
  - 1 Joker inspired by THE IDOLM@STER SideM × FiFS Exhibition
  - Embossing Joker, SUNSUN and Goldpeople: 1 each
  - Amehiko Kuzunoha and Sora Kitamura: 1 each

### Development Notes

For this project, I made extensive use of **ChatGPT-6.1Sol Codex**,
entrusting it with much of the implementation and the foundational design
of the Joker effects.

All illustrations used for the Jokers were created by me using
**CLIP STUDIO PAINT**, one little step at a time!

### Terms of Use

- This mod is a fan-made creation. Redistribution, including redistribution
  of modified versions by third parties, is prohibited.
- You are free to stream or create videos featuring this mod, provided
  the content does not violate public decency or accepted standards of conduct.
- Please do not use this mod to promote political or religious beliefs,
  or for hate speech.

### Installation (Windows / Steam Version of Balatro)

**Lovely Injector** and **Steamodded 26.1002.0 or later** are required.

#### 1. Install Lovely Injector

1. Download the Windows release from the [official Lovely Injector releases](https://github.com/ethangreen-dev/lovely-injector/releases).
2. Extract the ZIP and place `winmm.dll` next to `Balatro.exe`.

In Steam, right-click Balatro, then select **Manage → Browse local files**
to open the game folder. Follow Lovely's official instructions when upgrading.

#### 2. Install Steamodded

1. Download and extract [Steamodded](https://github.com/Steamodded/smods/releases).
2. Place its folder inside:

```text
%AppData%\Balatro\Mods
```

Create the `Mods` folder if it does not exist.

#### 3. Install Cafetro!

1. Download the attached `Cafetro-v1.2.0.zip` release file and extract it.
2. Place the `Cafetro` folder in `%AppData%\Balatro\Mods`.
   The resulting path should be:

```text
%AppData%\Balatro\Mods\Cafetro
```

3. Make sure `Cafetro.json` and `main.lua` are directly inside that folder.
4. Launch Balatro and check that **Cafetro!** appears in the **Mods** menu.

### Notes

- Back up your save data before installing mods.
- Avoid nested mod folders or keeping old and new copies installed together.
- If the game does not launch, check your Lovely and Steamodded installation
  and versions.
- This mod targets the Steam version of Balatro.

---

MOD Creator / Art: Potetan
