node(){
    
//   tools {nodejs "nodejs"}
    
    stage('Cloning Git') {
        checkout scm

    }
        
    stage('Install dependencies') {
        nodejs('nodejs') {
            sh 'npm install'
        }
        
    }
}