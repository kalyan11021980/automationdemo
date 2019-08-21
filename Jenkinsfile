node(){
    try {
        stage("checkout"){
            checkout scm
        }
        stage("Install Deps") {
            sh "npm install"
            echo "deps installed"
        }
    }
    catch ( Exception e){
        echo "Build failed"
        error ${error}
    }
}