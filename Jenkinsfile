node(){
    try {
        stage("checkout"){
            checkout scm
        }
        stage("Install Deps") {
            sh "export PATH=/Users/blackbox/.nvm/versions/node/v10.13.0/lib/node_modules/"
            sh "npm install"
            echo "deps installed"
        }
    }
    catch ( Exception e){
        echo "Build failed"
        error ${error}
    }
}