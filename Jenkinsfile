pipeline {
  agent any
  stages {
    stage('1') {
      steps {
        parallel(
          "1": {
            sh 'ls -la'
            
          },
          "222": {
            sh 'echo 2'
            
          }
        )
      }
    }
    stage('2323') {
      steps {
        sh 'echo 3'
      }
    }
  }
}