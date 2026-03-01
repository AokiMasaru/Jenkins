#!/bin/bash

# --- 設定項目 ---
JENKINS_URL="http://192.168.1.112:8080"
AGENT_NAME="agent-01"
# 必要に応じて API TOKEN を設定してください
AUTH="-u admin:admin"
WORK_DIR="/home/aokim/Company/jenkins/agent"
JAR_PATH="${WORK_DIR}/agent.jar"

# 1. agent.jar をダウンロード
# -z オプションで、サーバー側の方が新しい場合のみダウンロードするようにしています
echo "Checking for latest agent.jar..."
curl -s -L $AUTH "${JENKINS_URL}/jnlpJars/agent.jar" -o "$JAR_PATH" -z "$JAR_PATH"

if [ ! -f "$JAR_PATH" ]; then
    echo "Error: agent.jar のダウンロードに失敗しました。"
    exit 1
fi

# 2. 最新の Secret を取得
echo "Fetching latest secret for ${AGENT_NAME}..."
SECRET=$(curl -s $AUTH "${JENKINS_URL}/computer/${AGENT_NAME}/slave-agent.jnlp" \
    | grep -oP '(?<=<argument>)[a-f0-9]{64}(?=</argument>)' | head -n 1)

if [ -z "$SECRET" ]; then
    echo "Error: Jenkins からシークレットを取得できませんでした。"
    exit 1
fi

# 3. エージェントの起動
echo "Starting Jenkins agent..."
exec java -jar "$JAR_PATH" \
    -url "${JENKINS_URL}/" \
    -secret "$SECRET" \
    -name "$AGENT_NAME" \
    -webSocket \
    -workDir "$WORK_DIR"