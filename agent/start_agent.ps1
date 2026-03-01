# --- 設定項目 ---
$JENKINS_URL = "http://192.168.1.112:8080"
$AGENT_NAME = "agent-01"
# ユーザー名:APIトークンの形式で指定
$AUTH_USER = "admin"
$AUTH_TOKEN = "admin"
$WORK_DIR = "C:\jenkins\agent" # Windowsのパス形式に変更
$JAR_PATH = "$WORK_DIR\agent.jar"

# フォルダが存在しない場合は作成
if (!(Test-Path $WORK_DIR)) {
    New-Item -ItemType Directory -Force -Path $WORK_DIR
}

# 認証ヘッダーの準備 (Basic認証)
$Bytes = [System.Text.Encoding]::ASCII.GetBytes("${AUTH_USER}:${AUTH_TOKEN}")
$Base64 = [Convert]::ToBase64String($Bytes)
$Headers = @{ Authorization = "Basic $Base64" }

# 1. agent.jar をダウンロード
echo "Checking for latest agent.jar..."
# Windowsでは -z (If-Modified-Since) の代わりに簡易的なダウンロードを実装
Invoke-WebRequest -Uri "${JENKINS_URL}/jnlpJars/agent.jar" -OutFile $JAR_PATH -Headers $Headers

if (!(Test-Path $JAR_PATH)) {
    Write-Error "Error: agent.jar のダウンロードに失敗しました。"
    exit 1
}

# 2. 最新の Secret を取得
echo "Fetching latest secret for ${AGENT_NAME}..."
$xmlContent = Invoke-RestMethod -Uri "${JENKINS_URL}/computer/${AGENT_NAME}/slave-agent.jnlp" -Headers $Headers

# XMLからシークレット（1番目のargument）を抽出
# PowerShellはXMLを構造として扱えるため、grepより正確に抽出できます
$SECRET = $xmlContent.jnlp.#'application-desc'.argument[0]

if ([string]::IsNullOrWhiteSpace($SECRET)) {
    Write-Error "Error: Jenkins からシークレットを取得できませんでした。"
    exit 1
}

echo "Starting Jenkins agent with Secret: $SECRET"

# 3. エージェントの起動
Set-Location $WORK_DIR
java -jar "$JAR_PATH" `
    -url "${JENKINS_URL}/" `
    -secret "$SECRET" `
    -name "$AGENT_NAME" `
    -webSocket `
    -workDir "$WORK_DIR"