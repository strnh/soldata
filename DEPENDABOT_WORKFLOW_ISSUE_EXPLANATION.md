# Dependabot CIワークフロー失敗の解説

## 問題の概要

参照: https://github.com/strnh/soldata/actions/runs/20085399677/job/57621601548#step:3:1

2025年12月10日、Dependabotによる自動更新プロセスがGitHub Actions上で失敗しました。このワークフローは`dynamic/dependabot/dependabot-updates`パスで実行され、`npm_and_yarn`パッケージマネージャーを使用して`glob`パッケージの更新を試みていました。

## 失敗の詳細

### ワークフロー情報
- **ワークフローID**: 20085399677
- **ジョブ名**: Dependabot
- **ステータス**: 失敗 (failure)
- **トリガー**: Dependabotによる自動依存関係更新
- **対象**: globパッケージ (11.0.3 → 11.1.0へのアップグレード)

### 失敗のステップ
ステップ3「Run Dependabot」で失敗しました。このステップは通常、以下の処理を行います：
1. 依存関係の解析
2. 更新可能なパッケージの検出
3. 新しいバージョンとの互換性チェック
4. 更新の適用試行

## 根本原因

### 依存関係の競合

Dependabotは`glob`パッケージをバージョン11.0.3から11.1.0にアップグレードしようとしましたが、以下の理由で失敗しました：

1. **sqlite3の存在**: プロジェクトには`sqlite3@5.1.7`が依存関係として含まれていました
2. **間接依存関係**: sqlite3は以下の間接依存関係を通じて古いバージョンのglobを要求：
   - `cacache` (キャッシュライブラリ)
   - `node-gyp` (ネイティブモジュールビルドツール)
   - `rimraf` (ファイル削除ユーティリティ)
3. **バージョン競合**: これらの間接依存関係は`glob@^7.1.4`を要求し、glob 11.xとは互換性がありませんでした

### なぜsqlite3が問題だったのか

- このプロジェクトは**PostgreSQL**のみを使用（`pg-promise`経由）
- sqlite3は実際には使用されていない不要な依存関係でした
- しかし、package.jsonに含まれていたため、その依存関係ツリー全体がインストールされていました

## Dependabotの制限事項

### セキュリティ制約
Dependabotが生成するPRには以下の制限があります：

1. **読み取り専用トークン**: `GITHUB_TOKEN`は読み取り専用権限のみ
2. **シークレットへのアクセス制限**: 通常のGitHub Actionsシークレットにアクセスできません
3. **フォーク相当の扱い**: セキュリティのため、フォークからのPRと同様に扱われます

### ワークフロートリガーの問題
- Dependabotイベントは特別な扱いを受け、一部のワークフロー機能が制限されます
- `pull_request`イベントでトリガーされるワークフローは、Dependabot PRでは異なる動作をします

## 解決策

### 実施された修正 (PR #19)

PR #19「Fix action workflow error in CI pipeline」で以下の対応が実施されました：

1. **sqlite3の削除**: package.jsonから未使用のsqlite3依存関係を削除
   ```bash
   npm uninstall sqlite3
   ```

2. **package-lock.jsonの更新**: `npm install`を実行して依存関係を再構築

3. **結果**:
   - globが11.0.3から11.1.0に正常にアップグレード
   - 108個の不要なパッケージ(sqlite3関連)が削除
   - セキュリティ脆弱性が解消 (`npm audit`: 0 vulnerabilities)

### 検証

```bash
# glob のバージョン確認
npm ls glob

# 出力:
# dataentry@0.1.0
# └─┬ npm@11.6.3
#   ├─┬ @npmcli/map-workspaces@5.0.1
#   │ └── glob@11.1.0 deduped
#   └── glob@11.1.0
```

## Dependabotワークフローのベストプラクティス

### 1. 依存関係の最小化
- 使用していない依存関係は積極的に削除
- 定期的に`npm ls`で依存関係ツリーを確認
- `npm prune`で不要なパッケージを削除

### 2. ワークフローの設定

適切な権限を設定：
```yaml
permissions:
  contents: write        # Dependabot PRの自動マージに必要
  pull-requests: write  # PR操作に必要
```

Dependabot PRを除外する場合：
```yaml
if: github.actor != 'dependabot[bot]'
```

### 3. シークレットの扱い

Dependabot用のシークレットは別途設定：
- リポジトリ設定 → Secrets → Dependabot secrets
- 通常のActions secretsとは別管理

### 4. 自動承認とマージ

GitHub CLIを使用した自動化例：
```yaml
- name: Enable auto-merge for Dependabot PRs
  if: github.actor == 'dependabot[bot]'
  run: gh pr merge --auto --merge "$PR_URL"
  env:
    PR_URL: ${{github.event.pull_request.html_url}}
    GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

## 今後の推奨事項

### 1. 依存関係の監査
定期的に以下を実行：
```bash
# 未使用の依存関係を検出
npm ls --all
npx depcheck

# セキュリティ監査
npm audit
npm audit fix
```

### 2. Dependabot設定の最適化

`.github/dependabot.yml`の設定例：
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    reviewers:
      - "your-team"
    commit-message:
      prefix: "npm"
      include: "scope"
```

### 3. CI/CDパイプラインの改善
- Dependabot PRに対するテストの自動実行
- セキュリティスキャンの統合
- 自動マージ前の品質ゲートの設定

## 参考情報

### 関連ドキュメント
- [GitHub Dependabot トラブルシューティング](https://docs.github.com/en/code-security/dependabot/troubleshooting-dependabot/troubleshooting-dependabot-on-github-actions)
- [Dependabot自動化](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/automating-dependabot-with-github-actions)
- [npm依存関係管理](https://docs.npmjs.com/cli/v9/commands/npm-ls)

### 関連PR
- PR #19: Fix action workflow error in CI pipeline (マージ済み)
- PR #9: Bump express from 5.1.0 to 5.2.0 (マージ済み)

## まとめ

この問題は、**未使用の依存関係(sqlite3)が間接的にglobの古いバージョンを要求**していたことが原因でした。Dependabotは新しいバージョンとの互換性チェックに失敗し、更新プロセスが停止しました。

**解決のポイント**:
1. 未使用の依存関係を削除することで、依存関係ツリーを簡素化
2. 競合するバージョン制約を排除
3. セキュリティアップデートの適用を可能に

このケースは、**依存関係の定期的な見直しとクリーンアップの重要性**を示す良い例です。
