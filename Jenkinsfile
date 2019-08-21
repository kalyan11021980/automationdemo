node(){
    try {
        stage("checkout"){
            checkout scm
        }
        stage("Install Deps") {
            sh "export PATH=/sbin:/usr/sbin:/usr/bin:/usr/local/bin"
            sh "npm install"
            echo "deps installed"
        }
    }
    catch ( Exception e){
        echo "Build failed"
        error ${error}
    }
}