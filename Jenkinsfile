node(){
    try {
        stage("checkout"){
            checkout scm
        }
    }
    catch ( Exception e){
        echo "Build failed"
        error ${error}
    }
}