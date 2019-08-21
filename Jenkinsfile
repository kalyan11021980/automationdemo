pipeline {
  agent any
    
  tools {nodejs "nodejs"}
    
  stages {
        
    stage('Cloning Git') {
      steps {
        checkout scm
      }
    }
        
    stage('Install dependencies') {
      steps {
        sh 'npm install'
      }
    }      
  }
}