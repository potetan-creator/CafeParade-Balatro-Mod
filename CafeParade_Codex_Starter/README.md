# Café Parade × Balatro — Codex開発スターター v0.1

**これは完成MODではなく、Codexへ渡す制作資料・仮カード画像セットです。** Luaのゲーム能力とMOD登録はCodexがこれから実装します。現時点でZIPをそのままBalatroのModsフォルダへ入れても動きません。

## 収録物
- `CODEX_PROMPT.md` — Codex用のコピペできる総合依頼文。
- `CARD_SPEC.md` — 6枚の詳細能力仕様書。数値、対象、再発動、保存、コピー時などを定義。
- `COLOR_PALETTE.json` — 個人カラー・カードID・アトラス座標の機械可読データ。
- `ASSET_GUIDE.md` — 仮PNGの使い方と完成画像への差し替え。
- `assets/` — Steamoddedで使える6枚横並びアトラスと仮MODアイコン（1x・2x）。
- `art/source/` — 差し替え用の元画像。6枚とも284×380。
- `previews/` — 一覧画像と個別確認画像。
- `tools/build_atlas.py` — アトラス再生成ツール。

## Codexへの渡し方
1. このZIPを任意の開発フォルダへ解凍。
2. VS Code / Codexで解凍先をワークスペースとして開く。
3. `CODEX_PROMPT.md` の全文をCodexに渡すか「CODEX_PROMPT.md を読んで実装して」と指示する。
4. Codexが作ったLuaやlocalizationを確認し、Lovely + Steamodded導入済みのBalatroに配置してゲームでテストする。
5. 不具合があった場合はエラー画面・ログをCodexに見せて修正させる。

## 推奨インストール先（コード完成後）
- Windows: `%AppData%\Balatro\Mods\CafeParade\`
- LovelyはBalatro実行フォルダ、Steamoddedは上記Mods配下の別サブフォルダに設置。
- MODを使う前に `%AppData%\Balatro\` のセーブデータをバックアップ。

## 色について
5名のカラー値はアイマスDBの個人色一覧（ASOBISTAGEのアソビライト由来の整理）を参照。
https://imas-db.jp/misc/color.html
サタンのグレー `#777B85` は今回指定に基づくMOD独自色。

## 参考ドキュメント
https://docs.smods.dev/
https://docs.smods.dev/Game%20Objects/SMODS.Atlas/
https://docs.smods.dev/Game%20Objects/SMODS.Center/SMODS.Joker/
https://docs.smods.dev/API%20Documentation/Localization/
https://docs.smods.dev/Installation/Installing%20Steamodded%20windows/

## 権利
非公式のファン制作プロジェクト向け。ゲーム・原作の商標・キャラクター設定は各権利者に帰属します。画像は本パッケージ固有の仮図形で、原作のイラスト画像を転載したものではありません。配布する場合は各種ガイドラインを確認してください。
