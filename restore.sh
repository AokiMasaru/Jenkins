#!/bin/bash

# 引数チェック
if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file_name>"
    exit 1
fi

BACKUP_FILE=$1
VOLUME_NAME="jenkins_jenkins_home" # 復元先のボリューム名

# 1. バックアップファイルの存在確認
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: ファイル '$BACKUP_FILE' が見つかりません。"
    exit 1
fi

# 2. ボリュームの有無を確認し、なければ作成
if ! podman volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
    echo "ボリューム '$VOLUME_NAME' が存在しないため、新規作成します..."
    podman volume create "$VOLUME_NAME"
else
    echo "ボリューム '$VOLUME_NAME' は既に存在します。"
fi

# 3. リストアの実行
echo "ボリューム '$VOLUME_NAME' にデータを展開中..."

# カレントディレクトリを /backup に、ボリュームを /dest にマウントして展開
podman run --rm \
    -v "$VOLUME_NAME":/dest \
    -v "$(pwd)":/backup:ro \
    alpine tar -xvzf /backup/"$BACKUP_FILE" -C /dest

# 4. 結果の判定
if [ $? -eq 0 ]; then
    echo "------------------------------------------"
    echo "Success: ボリューム '$VOLUME_NAME' への復元が完了しました。"
    echo "podman-compose.yml 等のボリューム設定を確認し、コンテナを起動してください。"
else
    echo "Error: 復元処理中にエラーが発生しました。"
    exit 1
fi