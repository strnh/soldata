# Worklog — soldata

## 2025-12-14

- 作業開始: ローカル macOS (Podman VM) 環境で動作確認
- 依存管理: `JSON` パッケージの問題を修正（`require('JSON')` 削除、`package.json` から依存除去）。`yarn install` 実行。
- ルーティング/表示修正:
  - `routes/entry.js`: `req.body` 等のガード追加、`/entry/list` ルート追加
  - `routes/index.js`: `list` で `config/es.json` を渡すよう修正
  - `controller/readdb.js`: `listByMonth` を昇順化、比較を厳格化（`date::date`）
  - `views/listview.ejs`: 入力フォーム項目を自動生成して表示、数値を小数3桁に整形、スクロール可能コンテナと固定ヘッダ（JSで高さ調整）を追加
  - `views/index.ejs`: `/entry/list` へのリンク追加

- DB: Podman コンテナ内の `psql` を利用してスキーマ・シード適用を実施（ホストに psql がないためコンテナ内部で実行）。
- 検証: `/`, `/entry`, `/list`（および `/entry/list`） の表示を確認、主要エラーを修正済み。

## 次の優先作業 (提案)

- セキュリティ推奨事項対応（GitHub code scanning）を順次実施
- レイアウト微調整（列幅、固定ヘッダの安定化）
- CSV エクスポート / フィルタ追加

---

作業ログは自動生成ではなく手動編集で更新してください。必要ならスクリプト化しても良いです。
