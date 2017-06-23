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
            
          },
          "1111": {
            build '1'
            waitUntil()
            
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