FROM jenkins/jenkins:lts

# rootユーザーに切り替え（必要に応じて）
USER root

# 必要なパッケージをインストール（例: git, docker-cli など）
RUN apt-get update && apt-get install -y \
    git \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Jenkinsユーザーに戻す
USER jenkins

# プラグインのインストール
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# 初期ジョブや設定ファイルをコピー（必要に応じて）
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/
COPY jobs/ /usr/share/jenkins/ref/jobs/

# jenkins_homeの外のパスにコピーする
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
COPY agent.yaml /usr/share/jenkins/ref/agent.yaml
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref