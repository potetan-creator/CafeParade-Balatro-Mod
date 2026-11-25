# Cafetro! リリース作業

これは開発用の作業メモで、配布ZIPには含めません。ダウンロード者向けREADMEは、作者提供の文面を整理した `Cafetro/README.txt` です。

## 開発中の運用

カード追加やバランス調整を開発版へ蓄積し、追加のたびにバージョンを上げたり、新しいRelease下書きを作ったりしません。通常は現在のメタデータの番号を維持し、変更は `CHANGELOG.md` の未リリース欄へ記録します。検証とGitHubへの反映は通常どおり行い、CI成果物と既存の下書きZIPを確認用に使います。

現在の正式版はv1.0.0です。v1.1.0・v1.2.0の下書きはこれまでの未公開候補であり、次の正式版番号は公開時に確定します。ユーザーからリリース指示があるまでは正式公開しません。

## リリース指示を受けたとき

1. `Cafetro/Cafetro.json` と `Cafetro/README.txt` のバージョンを確認する。内部ID `CafeParade` とprefix `cp` は既存セーブのため変更しない。
2. 配布用READMEは **`Cafetro/README.txt`** を編集する。GitHub Releaseにも表示するため、Markdownの見出し・箇条書き・リンクを使える。原稿・テスト・開発資料をMOD本体へ戻さない。
3. 画像を更新したときだけ `python tools/build_atlas.py --filter nearest` を実行する。
4. `python tests/run.py` で能力・画像・配布ZIPを検証する。
5. `python tools/build_release.py` を実行する。`dist/Cafetro-v1.2.0.zip` と `dist/Cafetro-v1.2.0.sha256` を生成する。バージョン部分はメタデータに従う。
6. ZIPの最上位は `Cafetro/` ひとつで、その直下に `Cafetro.json` と `main.lua` がある。現在はREADME.txtを含む必要な36ファイルのみ。
7. GitHub Releaseの下書きにZIPとSHA-256を添付する。READMEを追加・変更したら再ビルドし、両方の添付を更新する。
8. 実ゲーム確認・README・リリース説明の準備ができたら下書きを公開する。

公開する番号へ未リリースの変更をまとめ、公開日を変更履歴へ記録します。使わなくなった候補の下書きは、その時点で内容を確認して整理します。

GitHub自動生成の「Source code」は開発リポジトリ全体です。インストール用の添付ZIPは `Cafetro-v<version>.zip`。配布フォルダ名は **Cafetro**、ゲーム内の表示名は **Cafetro!** です。

同一入力から同一ZIPを作れるよう、収録ファイルを明示し、並び順・日時・ファイル権限を固定しています。`art/`、`tests/`、`tools/`、`docs/`、旧MOD、過去の仮画像、開発用のお試しライブは入りません。作者の利用案内は `README.txt` に統合し、旧 `SAKI_CARDS_NOTICE.txt` は含めません。

`cafeparade-v0.1.0` のMOD本体・画像・生成ツール・テストを更新すると、GitHub Actionsでも検証とZIP作成を行います。対応バージョンのReleaseが下書きならZIPとSHA-256を差し替え、対象コミットとREADME.txtによるリリース説明を更新します。公開済みのReleaseは変更しません。`Cafetro/README.txt` を編集してpushした場合も同じ処理が動きます。
