import jenkins.model.*
import hudson.model.*
import hudson.tasks.Shell
import hudson.model.StringParameterDefinition
import hudson.model.ParametersDefinitionProperty

def jenkins = Jenkins.getInstance()

if (jenkins.getItem("my-parameterized-job") == null) {
    def job = jenkins.createProject(FreeStyleProject, "my-parameterized-job")
    job.setDescription("パラメータでコマンドを実行するジョブ")

    // Agent指定
    job.setAssignedLabel(jenkins.getLabel("linux build"))

    // パラメータ定義
    def params = new ParametersDefinitionProperty([
        new StringParameterDefinition("COMMAND", "echo hello", "実行するコマンド"),
        new StringParameterDefinition("WORK_DIR", "/home/jenkins", "作業ディレクトリ")
    ])
    job.addProperty(params)

    // パラメータを使ってコマンド実行
    def shell = new Shell("""
cd \${WORK_DIR}
\${COMMAND}
""")

    job.getBuildersList().add(shell)
    job.save()
}

jenkins.save()