import jenkins.model.*
import hudson.security.*
import hudson.model.User
import org.springframework.security.core.userdetails.UsernameNotFoundException

def jenkins = Jenkins.getInstance()
def realm = jenkins.getSecurityRealm()

def users = [
    [id: "user01", password: "user01pass", fullName: "ユーザー01", email: "user01@example.com"],
    [id: "user02", password: "user02pass", fullName: "ユーザー02", email: "user02@example.com"],
    [id: "user03", password: "user03pass", fullName: "ユーザー03", email: "user03@example.com"],
]

users.each { u ->
    boolean userExists = false
    try {
        // ユーザーが存在するか確認。存在しない場合は例外が発生するにゃ
        realm.loadUserByUsername2(u.id)
        userExists = true
    } catch (UsernameNotFoundException e) {
        userExists = false
    }

    if (!userExists) {
        // ユーザー作成
        realm.createAccount(u.id, u.password)
        
        // 作成されたユーザーオブジェクトを取得して詳細設定
        def userObj = User.get(u.id, false)
        if (userObj) {
            userObj.setFullName(u.fullName)
            def emailProp = new hudson.tasks.Mailer.UserProperty(u.email)
            userObj.addProperty(emailProp)
            userObj.save()
        }
        println "Created user: ${u.id}"
    } else {
        println "Skipped (already exists): ${u.id}"
    }
}

jenkins.save()